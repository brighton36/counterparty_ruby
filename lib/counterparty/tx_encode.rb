#encoding: utf-8

# Inspriration heavily lifted from: 
# - https://github.com/CounterpartyXCP/counterparty-lib/blob/master/counterpartylib/lib/transaction.py
class Counterparty::TxEncode
  class MissingPubkey < StandardError; end
  class MissingSenderAddr < StandardError; end
  class InvalidPubkey < StandardError; end
  class InvalidPubkeyGenerated < StandardError; end
  class DataTooLarge < StandardError; end

  PREFIX = 'CNTRPRTY'

  P2PKH = 'OP_DUP OP_HASH160 %s OP_EQUALVERIFY OP_CHECKSIG'
  MULTISIG = '1 %s %s OP_CHECKMULTISIG'
  OPRETURN = 'OP_RETURN %s'

  # 33 is the size of a pubkey, there are two pubkeys in a multisig, 1 byte
  # is lost for the data length byte, and two bytes are lost on each key for
  # the data_to_pubkey inefficiency
  BYTES_IN_MULTISIG = (33 * 2) - 1 - 2 - 2
  BYTES_IN_PUBKEYHASH = 20 - 1
  BYTES_IN_OPRETURN = 40

  attr_accessor :sender_addr, :sender_pubkey, :receiver_addr, :encrypt_key, 
    :source_data, :prefix
  
  def initialize(encrypt_key, source_data, options = {})
    @source_data, @encrypt_key = source_data, encrypt_key

    if options[:sender_pubkey]
      @sender_pubkey = options[:sender_pubkey]
      @sender_addr = Bitcoin.pubkey_to_address(sender_pubkey)
    elsif options.has_key? :sender_addr
      @sender_addr = options[:sender_addr]
    else
      raise MissingSenderAddr
    end

    @receiver_addr = options[:receiver_addr] if options.has_key? :receiver_addr

    @prefix = options[:prefix] || PREFIX
  end

  def to_opmultisig
    raise MissingPubkey unless sender_pubkey

    data_length = BYTES_IN_MULTISIG-prefix.length
    p2pkh_wrap collect_chunks(source_data,data_length){|chunk| 
      padding = 0.chr * (data_length-chunk.length)

      data = encrypt [(chunk.length+prefix.length).chr,prefix, chunk, padding].join

      data_keys = [(0...31), (31...62)].collect{|r| data_to_pubkey data[r] }

      MULTISIG % [(data_keys + [sender_pubkey]).join(' '), 3]
    }
  end

  def to_pubkeyhash
    p2pkh_wrap collect_chunks(source_data, BYTES_IN_PUBKEYHASH-prefix.length){ |chunk|
      data_length = prefix.length + chunk.length

      padding = 0.chr * (BYTES_IN_PUBKEYHASH - data_length)
  
      enc_chunk = encrypt [(data_length).chr, prefix, chunk, padding].join

      P2PKH % enc_chunk.unpack('H*').first
    }
  end

  def to_opreturn
    # I'm fairly certain that using more than one OP_RETURN per transaction is
    # unstandard behavior right now
    raise DataTooLarge if (source_data.length + prefix.length) > BYTES_IN_OPRETURN

    data = encrypt [prefix,source_data].join

    p2pkh_wrap( OPRETURN % data.unpack('H*').first )
  end

  def encrypt(chunk)
    RC4.new(encrypt_key).encrypt chunk
  end

  private

  def p2pkh_wrap(operation)
    [ (receiver_addr) ? P2PKH % Bitcoin.hash160_from_address(receiver_addr) : nil, 
      operation,
      P2PKH % Bitcoin.hash160_from_address(sender_addr) ].flatten.compact
  end

  # Take a too short data pubkey and make it look like a real pubkey.
  # Take an obfuscated chunk of data that is two bytes too short to be a pubkey and
  # add a sign byte to its beginning and a nonce byte to its end. Choose these
  # bytes so that the resulting sequence of bytes is a fully valid pubkey (i.e. on
  # the ECDSA curve). Find the correct bytes by guessing randomly until the check
  # passes. (In parsing, these two bytes are ignored.)
  #
  # NOTE: This function is named "make_fully_valid" in the official code. 
  def data_to_pubkey(bytes)
    raise InvalidPubkey unless bytes.length == 31

    random_bytes = Digest::SHA256.digest bytes

    # Deterministically generated, for unit tests.
    sign = (random_bytes[0].ord & 1) + 2
    nonce = initial_nonce = random_bytes[1].ord

    begin
      nonce += 1
      next if nonce == initial_nonce

      ret = (sign.chr + bytes + (nonce % 256).chr).unpack('H*').first

    # Note that 256 is the exclusive limit:
    end until Bitcoin.valid_pubkey? ret

    # I don't actually think this is ever possible. Note that we return 66 bytes
    # as this is string of hex, and not the bytes themselves:
    raise InvalidPubkeyGenerated unless ret.length == 66

    ret
  end

  # This is a little helper method that lets us split our binary data into 
  # chunks for further processing
  def collect_chunks(data,chunk_length, &block)
    (source_data.length.to_f / chunk_length).ceil.times.collect{|i| 
      block.call source_data.slice(i*chunk_length, chunk_length) }
  end
end
