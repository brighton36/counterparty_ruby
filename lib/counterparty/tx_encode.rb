# Inspriration heavily lifted from: 
# - https://github.com/CounterpartyXCP/counterparty-lib/blob/master/counterpartylib/lib/transaction.py
# Binary data to to bitcoin transaction encoder class/utility
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
  # the make_fully_valid inefficiency
  BYTES_IN_MULTISIG = (33 * 2) - 1 - 2 - 2

  BYTES_IN_OPRETURN = 40

  attr_accessor :sender_addr, :sender_pubkey, :receiver_addr, :encrypt_key, 
    :source_data, :prefix
  
  def initialize(receiver_addr, encrypt_key, source_data, options = {})
    @receiver_addr, @source_data, @encrypt_key = receiver_addr, source_data, 
      encrypt_key

    if options[:sender_privkey]
      # We don't need to store the privkey, but we do need to generate its pub
      # TODO
      raise StandardError, "TODO: pybitcointools can do it, `bitcoin.privtopub and test!"
    end

    if options[:sender_pubkey]
      @sender_pubkey = options[:sender_pubkey]
      @sender_addr = Bitcoin.pubkey_to_address(sender_pubkey)
    end

    @sender_addr = options[:sender_addr] if options[:sender_addr]

    raise MissingSenderAddr unless sender_addr

    @prefix = options[:prefix] || PREFIX
  end

  def to_opmultisig
    raise MissingPubkey unless sender_pubkey
    raise DataTooLarge if (source_data.length + prefix.length) > BYTES_IN_MULTISIG

    padding = 0.chr * (BYTES_IN_MULTISIG - prefix.length)

    data = encrypt [source_data.length.chr, prefix, source_data, padding].join

    data_keys = [(0...31), (31...62)].collect{|r| make_fully_valid data[r] }

    p2pkh_wrap(
      MULTISIG % [(data_keys + [sender_pubkey]).join(' '), data_keys.length+1] )
  end

  def to_opreturn
    raise DataTooLarge if (source_data.length + prefix.length) > BYTES_IN_OPRETURN

    data = encrypt [prefix,source_data].join

    p2pkh_wrap( OPRETURN % data.unpack('H*').first )
  end

  def to_pubkeyhash
    # TODO:

    # Here's how padding works in the pubkeyhash
    # assert pad_length >= 0
    # data_chunk = bytes([len(data_chunk)]) + data_chunk + (pad_length * b'\x00')
    # data_chunk = key.encrypt(data_chunk)
  end

  def encrypt(chunk)
    RC4.new(encrypt_key).encrypt chunk
  end

  private

  def p2pkh_wrap(operation)
    [ P2PKH % Bitcoin.hash160_from_address(receiver_addr), operation,
      P2PKH % Bitcoin.hash160_from_address(sender_addr) ].join("\n")
  end

  # Take a too short data pubkey and make it look like a real pubkey.
  # Take an obfuscated chunk of data that is two bytes too short to be a pubkey and
  # add a sign byte to its beginning and a nonce byte to its end. Choose these
  # bytes so that the resulting sequence of bytes is a fully valid pubkey (i.e. on
  # the ECDSA curve). Find the correct bytes by guessing randomly until the check
  # passes. (In parsing, these two bytes are ignored.)
  #
  # NOTE: This is a shitty name for a function, I only used it because it was
  #   the reference implementation's name. Interface, not implementation.
  def make_fully_valid(pubkey_bytes)
    raise InvalidPubkey unless pubkey_bytes.length == 31

    random_bytes = Digest::SHA256.digest pubkey_bytes

    # Deterministically generated, for unit tests.
    sign = (random_bytes[0].ord & 1) + 2
    nonce = initial_nonce = random_bytes[1].ord

    begin
      nonce += 1
      next if nonce == initial_nonce

      ret = (sign.chr + pubkey_bytes + (nonce % 256).chr).unpack('H*').first

    # Note that 256 is the exclusive limit:
    end until Bitcoin.valid_pubkey? ret

    # I don't actually think this is ever possible. Note that we return 66 bytes
    # as this is string of hex, and not the bytes themselves:
    raise InvalidPubkeyGenerated unless ret.length == 66

    ret
  end

  # TODO: 
  def self.create_tx
    # Roll up the encoding of multiple outputs into a transaction

  end
end
