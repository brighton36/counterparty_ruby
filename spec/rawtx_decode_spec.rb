require 'spec_helper'

describe RawTx do
  describe ".double_sha256" do
    # http://bitcoin.stackexchange.com/questions/2177/how-to-calculate-a-hash-of-a-tx
    genesis_block = '01000000010000000000000000000000000000000000000000000'+
      '000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D657320'+
      '30332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F6'+
      '6207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F205'+
      '2A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A6796'+
      '2E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C70'+
      '2B6BF11D5FAC00000000'
    genesis_double_sha = '4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB2127B7AFDEDA33B'

    pending
  end

  describe ".nibbles_to_ui" do
    it "should fail on byte arrays larger than 32 bits" do
      expect{ RawTx.nibbles_to_ui([1,0,0,0,0]) }.to raise_error(ArgumentError)
    end

    # Remember that the least significant byte is first here:
    it ("should convert 0x10 to 1") { expect(RawTx.nibbles_to_ui([1,0])).to eq(1) }
    it ("should convert 0x01 to 16") { expect(RawTx.nibbles_to_ui([0,1])).to eq(16) }
    it ("should convert 0xf to 15") { expect(RawTx.nibbles_to_ui([0xf])).to eq(15) }
    it ("should convert 0x11 to 17") { expect(RawTx.nibbles_to_ui([1,1])).to eq(17) }
    it ("should convert 0xf1 to 31") { expect(RawTx.nibbles_to_ui([0xf,1])).to eq(31) }
    it ("should convert 0xff to 255") { expect(RawTx.nibbles_to_ui([0xf,0xf])).to eq(255) }
  end
  
  describe ".bytes_to_base64_s" do
    it "should convert 0x14FB9C03D97E to FPucA91+" do
      bytes = [0x14, 0xFB, 0x9C, 0x03, 0xD9, 0x7E]
      expect(RawTx.bytes_to_base64_s bytes).to eq("FPucA9l+")
    end

    it "should convert 0x14FB9C03D9 to FPucA9k=" do
      bytes = [0x14, 0xFB, 0x9C, 0x03, 0xD9]
      expect(RawTx.bytes_to_base64_s bytes).to eq("FPucA9k=")
    end

    it "should convert 0x14FB9C03 to FPucAw==" do
      bytes = [0x14, 0xFB, 0x9C, 0x03]
      expect(RawTx.bytes_to_base64_s bytes).to eq("FPucAw==")
    end
  end

  describe "#to_hash" do
    # NOTE that these spec values were obtained via:
    # bitcoind -testnet decoderawtransaction [subject]
    subject{ RawTx.new(
      "0100000001ec549bdf53cfb319201d672fc0933500e48505724010dad615a9344b99" +
      "1721cc010000001976a9148025b288cb325d88bcd7ef5d1ab1f8827778d5ee88acff" +
      "ffffff03781e0000000000006951210286cdf9ec8742c452bd13299771fe40130124" +
      "038e2198ffc402204c48cc2d32da21033de0df1555e81783f42e00458d0b542ff293" +
      "d9d04fbc7704650448ee07728a8a210286b1e4f15de57fd34bde19cf64ad9302e454" +
      "c4c377677581a951579a124b86e753ae781e00000000000069512102a2cdf9ec8742" +
      "c452bd2214fe01c9f33b0d0066ed0efb90aa715400038c1c621921034f89bc707587" +
      "71a393416c21a12b651db3def9851bff574904762b86365caaea210286b1e4f15de5" +
      "7fd34bde19cf64ad9302e454c4c377677581a951579a124b86e753aec0ba770d0000" +
      "00001976a9148025b288cb325d88bcd7ef5d1ab1f8827778d5ee88ac00000000").to_hash }

    its(['ver']){should eq(1)}
    its(['lock_time']){should eq(0)}
    its(['size']){should eq(338)}
    its(['vin_sz']){should eq(1)}
    its(['vout_sz']){should eq(3)}

    its(['vin']) do 
      # If we're testing to base64, the hash would look like:
      # RawTx.bytes_to_base64_s(out_hash.scan(/../).collect(&:hex))
      should eq([
          { "txid" => "cc2117994b34a915d6da1040720585e4003593c02f671d2019b3cf53df9b54ec",
            "vout" => 1,
            "scriptSig" => {
              "hex" => "76a9148025b288cb325d88bcd7ef5d1ab1f8827778d5ee88ac"
            }, "sequence" => 4294967295 }])
    end

    its(['vout']) do 
      should eq( [ 
        { "value" => 0.00007800, "n" => 0,
          "scriptPubKey" => {
            "hex" => "51210286cdf9ec8742c452bd13299771fe40130124038e2198ffc40"+
              "2204c48cc2d32da21033de0df1555e81783f42e00458d0b542ff293d9d04f"+
              "bc7704650448ee07728a8a210286b1e4f15de57fd34bde19cf64ad9302e45"+
              "4c4c377677581a951579a124b86e753ae" }
        },
        { "value" => 0.00007800, "n" => 1,
          "scriptPubKey" => {
            "hex" => "512102a2cdf9ec8742c452bd2214fe01c9f33b0d0066ed0efb90aa71"+
              "5400038c1c621921034f89bc70758771a393416c21a12b651db3def9851bf"+
              "f574904762b86365caaea210286b1e4f15de57fd34bde19cf64ad9302e454"+
              "c4c377677581a951579a124b86e753ae" }
        },
        { "value" => 2.25950400, "n" => 2,
          "scriptPubKey" => {
            "hex" => "76a9148025b288cb325d88bcd7ef5d1ab1f8827778d5ee88ac" } } ] )
    end
  end
 
  describe("#to_hash coinbase") do

    subject{ RawTx.new(
      "01000000010000000000000000000000000000000000000000000000000000000000" + 
      "000000ffffffff53038349040d00456c69676975730052d8f72ffabe6d6dd991088d" + 
      "ecd13e658bbecc0b2b4c87306f637828917838c02a5d95d0e1bdff9b040000000000" +
      "0000002f73733331312f00906b570400000000e4050000ffffffff01bf2087950000" +
      "00001976a9145399c3093d31e4b0af4be1215d59b857b861ad5d88ac00000000").to_hash }

    pending
  end 

end

