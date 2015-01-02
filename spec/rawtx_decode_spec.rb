require 'spec_helper'

describe RawTx do
  describe ".bytes_to_ui" do
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

  describe "#to_json" do
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
=begin
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
      "00001976a9148025b288cb325d88bcd7ef5d1ab1f8827778d5ee88ac00000000").to_json }

    its([:version]){should eq(1)}
    
    #it "should decode a raw transaction" do
      #expect(RawTx.new(tx_raw).to_json).to eq(tx_json)
    #end
=end
  end

end

