=begin
decode_raw_tx = do ->
  { Transaction, TransactionIn, TransactionOut } = Bitcoin
  { bytesToBase64 } = Crypto.util
 
 
  u8  = (bytes) -> bytes.shift()
  u16 = parse_int 2
  u32 = parse_int 4
  # 64 bit numbers are kept as bytes
  # (bitcoinjs-lib expects them that way)
  u64 = (bytes) -> bytes.splice 0, 8
 
  # https://en.bitcoin.it/wiki/Protocol_specification#Variable_length_integer
  varint = (bytes) ->
    switch n = u8 bytes
      when 0xfd then u16 bytes
      when 0xfe then u32 bytes
      when 0xff then u64 bytes
      else n
 
  # https://en.bitcoin.it/wiki/Protocol_specification#Variable_length_string
  varchar = (bytes) -> bytes.splice 0, varint bytes
 
 
    tx
=end

require 'spec_helper'

class RawTx
  def initialize(as_hexstring)
    @hexstring = as_hexstring
  end

  def to_json
    ret = {in: [], out: []}

    bytes = @hexstring.chars.collect(&:hex)
    version = slice_u32(bytes)

    raise ArgumentError, "Unsupported Version/Tx" unless version == 0x01

    # Parse inputs TODO: Collect these
    in_count = slice_varint bytes
    0.upto(in_count) do
      ret[:in] << { outpoint: {
          hash: self.class.bytes_to_base64_s(bytes.slice(32)),
          index: slice_u32(bytes) },
        script: slice_varchar(bytes),
        seq: slice_u32(bytes)
      }
    end

    # Parse outputs TODO: Collect these
    out_count = slice_varint bytes
    0.upto(out_count) do
      ret[:out] << { value: slice_u64(bytes), script: slice_varchar(bytes) }
    end

    ret[:lock_time] = slice_u32(bytes) 
    ret
  end

  # Parse an bytearray, works for numbers up to 32-bit only
  def self.bytes_to_ui(bytes)
    raise ArgumentError if bytes.length > 4

    bytes.reverse.each_with_index.inject(0){ |sum, (b,i)|
      sum += (b.to_i & 0xff) << (4 * i) }
  end

  def self.bytes_to_base64_s(bytes)
    ""
=begin
     // Convert a byte array to a base-64 string
        bytesToBase64: function (bytes) {

                // Use browser-native function if it exists
                if (typeof btoa == "function") return btoa(Binary.bytesToString(bytes));

                for(var base64 = [], i = 0; i < bytes.length; i += 3) {
                        var triplet = (bytes[i] << 16) | (bytes[i + 1] << 8) | bytes[i + 2];
                        for (var j = 0; j < 4; j++) {
                                if (i * 8 + j * 6 <= bytes.length * 8)
                                        base64.push(base64map.charAt((triplet >>> 6 * (3 - j)) & 0x3F));
                                else base64.push("=");
                        }
                }

                return base64.join("");

        },
=end
  end

  private 
  
  # https://en.bitcoin.it/wiki/Protocol_specification#Variable_length_string
  def slice_varchar(bytes)
    bytes.slice varint(bytes)
  end

  def slice_varint(bytes)
    n = slice_u8 bytes
    case n
      when 0xfd then slice_u16 bytes
      when 0xfe then slice_u32 bytes
      when 0xff then slice_u64 bytes
      else n
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

describe RawTx do
  describe "Unsigned Integer conversions" do
    it "should fail on byte arrays larger than 32 bits" do
      expect{ RawTx.bytes_to_ui([1,0,0,0,0]) }.to raise_error(ArgumentError)
    end

    it ("should convert 0x01 to 1") { expect(RawTx.bytes_to_ui([0,1])).to eq(1) }
    it ("should convert 0xf to 15") { expect(RawTx.bytes_to_ui([0xf])).to eq(15) }
    it ("should convert 0x10 to 16") { expect(RawTx.bytes_to_ui([1,0])).to eq(16) }
    it ("should convert 0x11 to 17") { expect(RawTx.bytes_to_ui([1,1])).to eq(17) }
    it ("should convert 0xf1 to 241") { expect(RawTx.bytes_to_ui([0xf,1])).to eq(241) }
    it ("should convert 0xff to 255") { expect(RawTx.bytes_to_ui([0xf,0xf])).to eq(255) }
  end
  
  describe "Base64 string conversions" do
    it "should convert 0x14FB9C03D97E to FPucA91+" do
      bytes = [0x1,0x4,0xF,0xB,0x9,0xC,0x0,0x3,0xD,0x9,0x7,0xE]
      expect(RawTx.bytes_to_base64_s bytes).to eq("FPucA9l+")
    end

    it "should convert 0x14FB9C03D97E to FPucA9k=" do
      bytes = [0x1,0x4,0xF,0xB,0x9,0xC,0x0,0x3,0xD,0x9,0xD,0x9]
      expect(RawTx.bytes_to_base64_s bytes).to eq("FPucA9k=")
    end

    it "should convert 0x14FB9C03D97E to FPucAw==" do
      bytes = [0x1,0x4,0xF,0xB,0x9,0xC,0x0,0x3]
      expect(RawTx.bytes_to_base64_s bytes).to eq("FPucAw==")
    end
  end

  describe "Transaction Decoding" do
    let(:tx_raw) { 
      "0100000001ec549bdf53cfb319201d672fc0933500e48505724010dad615a9344b99" +
      "1721cc010000001976a9148025b288cb325d88bcd7ef5d1ab1f8827778d5ee88acff" +
      "ffffff03781e0000000000006951210286cdf9ec8742c452bd13299771fe40130124" +
      "038e2198ffc402204c48cc2d32da21033de0df1555e81783f42e00458d0b542ff293" +
      "d9d04fbc7704650448ee07728a8a210286b1e4f15de57fd34bde19cf64ad9302e454" +
      "c4c377677581a951579a124b86e753ae781e00000000000069512102a2cdf9ec8742" +
      "c452bd2214fe01c9f33b0d0066ed0efb90aa715400038c1c621921034f89bc707587" +
      "71a393416c21a12b651db3def9851bff574904762b86365caaea210286b1e4f15de5" +
      "7fd34bde19cf64ad9302e454c4c377677581a951579a124b86e753aec0ba770d0000" +
      "00001976a9148025b288cb325d88bcd7ef5d1ab1f8827778d5ee88ac00000000" }

    let(:tx_json) do 
      { hash: "70b1da7516c70608de9a312002a4b6c7e376948164542953d5c1949a66866a6f",
        ver: 1, vin_sz: 1, vout_sz: 3, lock_time: 0,
        size: 338, 
        in: [
          { prev_out: {
            hash: "cc2117994b34a915d6da1040720585e4003593c02f671d2019b3cf53df9b54ec",
            n: 1 },
            scriptSig: "OP_DUP OP_HASH160 8025b288cb325d88bcd7ef5d1ab1f8827778d5ee OP_EQUALVERIFY OP_CHECKSIG",
            sequence: 4294967295
          }
        ], 
        out: [ 
          { value: "0.00007800",
            scriptPubKey: "OP_TRUE 0286cdf9ec8742c452bd13299771fe40130124038e2198ffc402204c48cc2d32da 033de0df1555e81783f42e00458d0b542ff293d9d04fbc7704650448ee07728a8a 0286b1e4f15de57fd34bde19cf64ad9302e454c4c377677581a951579a124b86e7 OP_3 OP_CHECKMULTISIG" },
            { value: "0.00007800",
              scriptPubKey: "OP_TRUE 02a2cdf9ec8742c452bd2214fe01c9f33b0d0066ed0efb90aa715400038c1c6219 034f89bc70758771a393416c21a12b651db3def9851bff574904762b86365caaea 0286b1e4f15de57fd34bde19cf64ad9302e454c4c377677581a951579a124b86e7 OP_3 OP_CHECKMULTISIG" },
            { value: "2.25950400",
              scriptPubKey: "OP_DUP OP_HASH160 8025b288cb325d88bcd7ef5d1ab1f8827778d5ee OP_EQUALVERIFY OP_CHECKSIG" }
        ]
      }
    end

    #it "should decode a raw transaction" do
      #expect(RawTx.new(tx_raw).to_json).to eq(tx_json)
    #end
  end

end

