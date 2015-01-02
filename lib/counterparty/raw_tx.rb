# This class is mostly used to decode json transactions from raw transactions
# much of this implementation was inspired from: 
# https://gist.github.com/shesek/5835695
class RawTx
  # This is a map of offset to characters used for decoding base64 strings:
  BASE64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

  # Creates a raw transaction from a hexstring
  def initialize(as_hexstring)
    @hexstring = as_hexstring.downcase
    raise ArgumentError, "Unsupported hex" unless /\A[0-9a-f]+\Z/.match @hexstring
  end

  # Returns this transaction in a standard json format
  def to_hash(options = {})
    bytes = @hexstring.scan(/../).collect(&:hex)
    size = bytes.length

    # Now we start shift elements off the byte stack:
    version = shift_u32(bytes)

    raise ArgumentError, "Unsupported Version/Tx" unless version == 0x01

    # Parse the inputs:
    ins = (0...shift_varint(bytes)).collect do
      hash = bytes.slice!(0,32).reverse.collect{|n| '%02x' % n}.join
      index,script,seq = shift_u32(bytes),shift_varchar(bytes),shift_u32(bytes)

      # NOTE: We may want to base64 encode the hash, or support this via an 
      # option : self.class.bytes_to_base64_s(hash).reverse),
      { 'prev_out' => { 'hash' => hash, 'n' => index },
        'scriptSig' => disassemble_script(script), 'seq' => seq }
    end

    # Parse outputs:
    outs = (0...shift_varint(bytes)).collect do
      value, script = shift_u64(bytes), shift_varchar(bytes)

      { 'value' => "%.8f" % [self.class.bytes_to_ui(value).to_f/1e8], 
        'scriptPubKey' => disassemble_script(script) }
    end

    lock_time = shift_u32 bytes

    {'in' => ins, 'out' => outs, 'lock_time' => lock_time, 'ver' => version, 
      'vin_sz' => ins.length, 'vout_sz' => outs.length, 'size' => size}
  end

  # Convert an array of 4 bit numbers into an unsigned int, 
  # works for numbers up to 32-bit only
  def self.nibbles_to_ui(nibbles)
    raise ArgumentError if nibbles.length > 4

    nibbles.each_with_index.inject(0){ |sum, (b,i)|
      sum += (b.to_i & 0xff) << (4 * i) }
  end

  # Convert an array of 8 bit numbers into an unsigned int,
  # Remember that for each input byte, the most significant nibble comes last.
  def self.bytes_to_ui(bytes)
    nibbles = bytes.collect{|b| [b & 0x0f, b >> 4]}.flatten
    nibbles.each_with_index.inject(0){|sum,(b,i)| sum += b * 16**i}
  end

  # Convert an array of bytes to a base64 string.
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

  def disassemble_script(bytes)
    # We don't actually need to reference a hash argument to acheive disassembly:
    btc_script = Bitcoin::Script.new String.new
    chunks = btc_script.parse bytes.pack('C*')
    btc_script.to_string chunks
  end

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
      self.class.nibbles_to_ui bytes.slice!(0,n)
    end
  end

  # 64 bit requests are an exception, and kept as 8-byte arrays:
  def shift_u64(bytes)
    bytes.slice!(0,8)
  end
end
