# This class is mostly used to decode json transactions from raw transactions
class RawTx
  # This is a map of offset to characters used for decoding base64 strings:
  BASE64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

  # Creates a raw transaction from a hexstring
  def initialize(as_hexstring)
    @hexstring = as_hexstring.downcase
    raise ArgumentError, "Unsupported hex" unless /\A[0-9a-f]+\Z/.match @hexstring
  end

  # Returns this transaction in a standard json format
  def to_json(options = {})
    bytes = @hexstring.scan(/../).collect(&:hex)
    size = bytes.length

    # Double sha256 is your hash:
    #hash = Digest::SHA2.new.update(Digest::SHA2.new.update(
      #"".tap {|binary| @hexstring.scan(/../) {|hn| binary << hn.to_i(16).chr}}

    #).to_s).to_s

    # Now we start shift elements off the byte stack:
    version = shift_u32(bytes)

    raise ArgumentError, "Unsupported Version/Tx" unless version == 0x01

    # Parse the inputs:
    ins = (0...shift_varint(bytes)).collect do
      { outpoint: {
          # TODO: Put this in an options{}
          #hash: self.class.bytes_to_base64_s(bytes.slice!(0,32).reverse),
          hash: bytes.slice!(0,32).reverse.collect{|n| '%02x' % n}.join,
          index: shift_u32(bytes) },
        script: shift_varchar(bytes),
        seq: shift_u32(bytes) }
    end

    # Parse outputs TODO: Collect these
    outs = (0...shift_varint(bytes)).collect do
      { value: shift_u64(bytes), script: shift_varchar(bytes) }
    end

    lock_time = shift_u32 bytes

    {in: ins, out: outs, lock_time: lock_time, ver: version, 
      vin_sz: ins.length, vout_sz: outs.length, size: size}
  end

  # Parse an bytearray, works for numbers up to 32-bit only
  def self.bytes_to_ui(bytes)
    raise ArgumentError if bytes.length > 4

    bytes.each_with_index.inject(0){ |sum, (b,i)|
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
  def shift_varchar(bytes)
    bytes.slice! 0, shift_varint(bytes)
  end

  # https://en.bitcoin.it/wiki/Protocol_specification#Variable_length_integer
  def shift_varint(bytes)
    n = shift_u8 bytes
    case n
      when 0xfd then shift_u16 bytes
      when 0xfe then shift_u32 bytes
      when 0xff then shift_u64 bytes
      else n
    end
  end
  
  # These are numeric byte-shift short-cuts that make for more readable code 
  # above:
  [1,2,4].each do |n|
    define_method('shift_u%s' % [n*8]) do |bytes| 
      self.class.bytes_to_ui bytes.slice!(0,n)
    end
  end

  # 64 bit requests are an exception, and kept as 8-byte arrays:
  def shift_u64(bytes)
    bytes.slice!(0,8)
  end
end
