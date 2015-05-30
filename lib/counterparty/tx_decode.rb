# Inspriration heavily lifted from: 
# - https://github.com/tokenly/counterparty-transaction-parser
class Counterparty::TxDecode
  DEFAULT_PREFIX = 'CNTRPRTY' #TODO: Add the version stuff here

  OP_RETURN_PARTS = /^OP_RETURN ([a-z0-9]+)$/
  OP_CHECKSIG_PARTS = /^OP_DUP OP_HASH160 ([a-z0-9]+) OP_EQUALVERIFY OP_CHECKSIG$/
  OP_MULTISIG_PARTS = /^1 ([a-z0-9 ]+) ([23]) OP_CHECKMULTISIG$/

  attr_accessor :destination, :data, :prefix

  def initialize(tx, prefix = DEFAULT_PREFIX) # TODO: Make this an option
    @tx, @prefix = tx, prefix
    parse!
  end
   
  def decrypt_key
    @decrypt_key ||= [@tx.inputs[0].prev_out.reverse_hth].pack('H*')
  end

  def decrypt(chunk)
    RC4.new(decrypt_key).decrypt chunk
  end

  def encoding_type
    # TODO: Return one of : multisig, opreturn, pubkeyhash
  end

  private

  def parse!
    return if @data

    destinations = []
    @data = @tx.outputs.inject(''){ |data, out|
      new_destination, new_data = case out.parsed_script.to_string
        when OP_RETURN_PARTS
          data_from_opreturn $1
        when OP_CHECKSIG_PARTS
          data_from_opchecksig $1
        when OP_MULTISIG_PARTS
          data_from_opcheckmultisig $1, $2
      end

      raise StandardError, 'Found new destination and new data' if new_destination && new_data
      raise StandardError, 'Did not find destination or data' unless new_destination || new_data

      # All destinations come before all data.
      if (data.empty? && new_data.nil?)
        destinations << new_destination;
      elsif new_destination.nil?
        data += new_data
      end

      data
    }

    @destination = case destinations.length
      when 0
        nil
      when 1
        destinations.first
      else
        raise StandardError, "Too many destinations parsed" if destinations.length > 1
    end
  end

  def data_from_opreturn(data)
    chunk = [data].pack('H*')
    
    raise StandardError "Invalid OP_RETURN" if chunk.nil?

    data = decrypt chunk

    raise StandardError "unrecognized OP_RETURN output" unless data[0...prefix.length] == prefix

    data = data[prefix.length..-1]

    [nil, data]
  end

  def data_from_opchecksig(pubkeyhash_text)
    chunk = decrypt [pubkeyhash_text].pack('H*')

    if (chunk[1..prefix.length] == prefix) 
      raise StandardError, "TODO: This Codepath is untested"
      # TODO:
      # $data_chunk_length = $chunk[0];
      # $data_chunk = substr($chunk, 1, $data_chunk_length + 1);
      # $data = substr($data_chunk, 8);

      # [nil, data]
    else
      [Bitcoin.hash160_to_address(pubkeyhash_text), nil]
    end
  end

  def data_from_opcheckmultisig(pubkeys_op, n_signatures_op)
    pubkeys, n_signatures = pubkeys_op.split(' '), n_signatures_op.to_i

    # There's no data in the last pubkey:
    chunk = pubkeys[0...-1].collect{ |pubkey|
      [pubkey].pack('H*')[1...-1] # Skip sign byte and nonce byte.
    }.reduce(:+)

    data = decrypt chunk

    if (data[1..prefix.length] == prefix) 
      # Padding byte in each output (instead of just in the last one) so that 
      # encoding methods may be mixed. Also, it’s just not very much data.

      chunk_length = data[0..1].unpack('c*')[1]

      data = data[1..chunk_length]
      data = data[prefix.length..-1]
      [nil, data]
    else
      raise StandardError, "TODO: This Codepath is untested" 
      # TODO: 
      # $pubkeyhashes = [];
      # foreach($pubkeys as $pubkey) {
          #$pubkeyhashes[] = self::pubkey_to_pubkeyhash($pubkey);
      # }
      # $destination = implode('_', array_merge([$sig_n], $pubkeyhashes, [count($pubkeyhashes)]));

      # [destination, nil]
    end
  end
end
