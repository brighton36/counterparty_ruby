#encoding: utf-8

# Inspriration heavily lifted from: 
# - https://github.com/tokenly/counterparty-transaction-parser
class Counterparty::TxDecode
  class UndefinedBehavior < StandardError; end # If you find one of these, lmk!
  class InvalidOpReturn < StandardError; end
  class InvalidOutput < StandardError; end
  class MultisigUnsupported < StandardError; end

  DEFAULT_PREFIX = 'CNTRPRTY'

  OP_RETURN_PARTS = /^OP_RETURN ([a-z0-9]+)$/
  P2PKH_PARTS = /^OP_DUP OP_HASH160 ([a-z0-9]+) OP_EQUALVERIFY OP_CHECKSIG$/
  OP_MULTISIG_PARTS = /^[12] ([a-z0-9 ]+) ([23]) OP_CHECKMULTISIG$/

  attr_accessor :sender_addr, :receiver_addr, :decrypt_key, :data, :prefix

  def initialize(tx, options = {})
    @prefix = options[:prefix] || DEFAULT_PREFIX
    @decrypt_key = options[:decrypt_key] || [tx.inputs[0].prev_out.reverse_hth].pack('H*')
    
    parse! (tx.respond_to? :outputs) ? 
      tx.outputs.collect{|out| out.parsed_script.to_string } : tx
  end

  def decrypt(chunk)
    RC4.new(decrypt_key).decrypt chunk
  end

  private

  def prefixed?(data, offset = 1)
    data[offset...(prefix.length+offset)] == prefix
  end

  # This determines if the supplied operation is a non-data 
  def is_non_prefixed_p2pkh?(op)
    P2PKH_PARTS.match(op) && !prefixed?(decrypt([$1].pack('H*')))
  end

  def hash160_from_p2pkh(op)
    Bitcoin.hash160_to_address $1 if P2PKH_PARTS.match op
  end

  # Note that this isn't exactly the way counterparty parses the transactions. 
  # But , it reads cleaner, and worked on every transaction I could find. 
  # Mostly the difference is that the counterparty version is a loop that 
  # collects P2PKH's anywhere in the outputs, whereas this block takes a sender
  # or receiver address from the top and bottom only
  def parse!(outputs)
    return if @data
    
    # So typically, the first output is a P2PKH with the receiver address:
    @receiver_addr = hash160_from_p2pkh outputs.shift if is_non_prefixed_p2pkh? outputs.first

    # Parse the sender address:
    @sender_addr = hash160_from_p2pkh outputs.pop if is_non_prefixed_p2pkh? outputs.last

    @data = outputs.collect{|out|
      # This weirdo line will send the regex matches to the operation handler
      # that matches the line
      send (case out
        when OP_RETURN_PARTS then :data_from_opreturn
        when P2PKH_PARTS then :data_from_opchecksig
        when OP_MULTISIG_PARTS then :data_from_opcheckmultisig
        else raise InvalidOutput
      end), *$~.to_a[1..-1]
    }.compact.join
  end

  def data_from_opreturn(data)
    chunk = [data].pack('H*')
    
    raise InvalidOpReturn if chunk.nil?

    data = decrypt chunk

    raise InvalidOpReturn unless prefixed?(data,0)

    data[prefix.length..-1]
  end

  def data_from_opchecksig(pubkeyhash_text)
    chunk = decrypt [pubkeyhash_text].pack('H*')

    # This should get picked up by the sender and receiver pop/shift in parse!
    # However, the counterparty lib would parse these obtuse addresses typically
    # ATM - I can't find one in the wild
    raise UndefinedBehavior unless prefixed? chunk
    
    chunk_length = chunk[0].ord
    chunk[(1+prefix.length)...chunk_length+1]
  end

  def data_from_opcheckmultisig(pubkeys_op, n_signatures_op)
    pubkeys, n_signatures = pubkeys_op.split(' '), n_signatures_op.to_i

    # There's no data in the last pubkey:
    chunk = pubkeys[0...-1].collect{ |pubkey|
      [pubkey].pack('H*')[1...-1] # Skip sign byte and nonce byte.
    }.reduce(:+)

    data = decrypt chunk

    # Multisig transactions will break here. I haven't actually collected enough
    # of these samples yet to really test, but it seems they are typically are
    # at the top of the output stack:
    raise MultisigUnsupported unless prefixed? data

    # Padding byte in each output (instead of just in the last one) so that 
    # encoding methods may be mixed. Also, it’s just not very much data.
    chunk_length = data[0].ord

    data[1..chunk_length][prefix.length..-1]
  end
end
