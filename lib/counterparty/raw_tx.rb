# This class is mostly used to decode json transactions from raw transactions
class RawTx
  # This is a map of offset to characters used for decoding base64 strings:
  BASE64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

  # Creates a raw transaction from a hexstring
  def initialize(as_hexstring)
    @hexstring = as_hexstring
  end

  # Returns this transaction in a standard json format
  def to_json
    #TODO: These are words, not bytes
    bytes = @hexstring.chars.collect(&:hex)
    version = slice_u32(bytes)

    raise ArgumentError, "Unsupported Version/Tx" unless version == 0x01

    # Parse inputs TODO: Collect these
    in_count = slice_varint bytes
    ins = []
    0.upto(in_count) do
      ins << { outpoint: {
          hash: self.class.bytes_to_base64_s(bytes.slice(32)),
          index: slice_u32(bytes) },
        script: slice_varchar(bytes),
        seq: slice_u32(bytes) }
    end

    # Parse outputs TODO: Collect these
    out_count = slice_varint bytes
    outs = []
    0.upto(out_count) do
      outs << { value: slice_u64(bytes), script: slice_varchar(bytes) }
    end

    lock_time = slice_u32 bytes

    {in: ins, out: outs, lock_time: lock_time, ver: version, vin_sz: ins.length,
     vout_sz: outs.length, lock_time: nil, size: nil}
  end

  # Parse an bytearray, works for numbers up to 32-bit only
  def self.bytes_to_ui(bytes)
    raise ArgumentError if bytes.length > 4

    bytes.reverse.each_with_index.inject(0){ |sum, (b,i)|
      sum += (b.to_i & 0xff) << (4 * i) }
  end

  def self.bytes_to_base64_s(input_bytes)
    input_bytes.each_slice(3).collect.with_index{ |bytes,i|
      # This is the base offset of this 3-byte slice in the sequence:
      i_triplet = i*3 

      # Here we compose a triplet by or'ing the shifted bytes:
      triplet = bytes.collect.with_index{|b,j| b << 8*(2-j) }.reduce(:|)

      # And here we convert to chars, unless with equals as nil-padding:
      0.upto(3).collect do |j| 
        (i_triplet * 8 + j * 6 <= input_bytes.length * 8) ? 
          BASE64_CHARS[((triplet >> 6 * (3 - j)) & 0x3F)] : '=' 
      end
    }.join

  end

  private 

  # https://en.bitcoin.it/wiki/Protocol_specification#Variable_length_string
  def slice_varchar(bytes)
    bytes.slice slice_varint(bytes)
  end

  # https://en.bitcoin.it/wiki/Protocol_specification#Variable_length_integer
  def slice_varint(bytes)
    n = slice_u8 bytes
    case n
      when 0xfd then slice_u16 bytes
      when 0xfe then slice_u32 bytes
      when 0xff then slice_u64 bytes
      else n
    end
  end
  
  # TODO: Maybe make thsi a bit more dry/introspective with an itereator over power
  # s of two
  def slice_u8(bytes); self.class.bytes_to_ui bytes.slice(1); end
  def slice_u16(bytes); self.class.bytes_to_ui bytes.slice(2); end
  def slice_u32(bytes); self.class.bytes_to_ui bytes.slice(4); end
  #def slice_u64(bytes); self.class.bytes_to_ui bytes.slice(8); end

  # TODO: This wise? 64 bit numbers are kept as bytes
  # (bitcoinjs-lib expects them that way)
  def slice_u64(bytes); bytes.slice(8); end

end
