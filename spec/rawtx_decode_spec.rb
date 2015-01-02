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

  describe ".bytes_to_ui" do
    it "should fail on byte arrays larger than 32 bits" do
      expect{ RawTx.bytes_to_ui([1,0,0,0,0]) }.to raise_error(ArgumentError)
    end

    # Remember that the least significant byte is first here:
    it ("should convert 0x10 to 1") { expect(RawTx.bytes_to_ui([1,0])).to eq(1) }
    it ("should convert 0x01 to 16") { expect(RawTx.bytes_to_ui([0,1])).to eq(16) }
    it ("should convert 0xf to 15") { expect(RawTx.bytes_to_ui([0xf])).to eq(15) }
    it ("should convert 0x11 to 17") { expect(RawTx.bytes_to_ui([1,1])).to eq(17) }
    it ("should convert 0xf1 to 31") { expect(RawTx.bytes_to_ui([0xf,1])).to eq(31) }
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

  describe "#to_hash" do
    let(:tx_json) do 
      # This was pulled from: https://brainwallet.github.io/#tx
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

    its([:ver]){should eq(1)}
    its([:lock_time]){should eq(0)}
    its([:size]){should eq(338)}
    its([:vin_sz]){should eq(1)}
    its([:vout_sz]){should eq(3)}

    its([:in]) do 
      out_hash = tx_json[:in][0][:prev_out][:hash]
      out_hash_base64 = RawTx.bytes_to_base64_s(out_hash.scan(/../).collect(&:hex))

      should eq([{
        outpoint: { hash: "cc2117994b34a915d6da1040720585e4003593c02f671d2019b3cf53df9b54ec",
           index: 1}, 
        script: [118, 169, 20, 128, 37, 178, 136, 203, 50, 93, 136, 188, 215, 
          239, 93, 26, 177, 248, 130, 119, 120, 213, 238, 136, 172],
        # NOTE: The :seq field isnt actually used right now, so some rawtx decoders
        # return the varint (like decoder), and some return UINT_MAX
        seq: 1114095}] )
    end

    its([:out]) do 
      should eq( [ 
        { :value=>[120, 30, 0, 0, 0, 0, 0, 0], :script=>[81, 33, 2, 134, 205, 
          249, 236, 135, 66, 196, 82, 189, 19, 41, 151, 113, 254, 64, 19, 1, 36, 
          3, 142, 33, 152, 255, 196, 2, 32, 76, 72, 204, 45, 50, 218, 33, 3, 61, 
          224, 223, 21, 85, 232, 23, 131, 244, 46, 0, 69, 141, 11, 84, 47, 242, 
          147, 217, 208, 79, 188, 119, 4, 101, 4, 72, 238, 7, 114, 138, 138, 33, 
          2, 134, 177, 228, 241, 93, 229, 127, 211, 75, 222, 25, 207, 100, 173, 
          147, 2, 228, 84, 196, 195, 119, 103, 117, 129, 169, 81, 87, 154, 18, 
          75, 134, 231, 83, 174]}, 
        { :value=>[120, 30, 0, 0, 0, 0, 0, 0], :script=>[81, 33, 2, 162, 205, 
          249, 236, 135, 66, 196, 82, 189, 34, 20, 254, 1, 201, 243, 59, 13, 0, 
          102, 237, 14, 251, 144, 170, 113, 84, 0, 3, 140, 28, 98, 25, 33, 3, 
          79, 137, 188, 112, 117, 135, 113, 163, 147, 65, 108, 33, 161, 43, 101, 
          29, 179, 222, 249, 133, 27, 255, 87, 73, 4, 118, 43, 134, 54, 92, 170, 
          234, 33, 2, 134, 177, 228, 241, 93, 229, 127, 211, 75, 222, 25, 207, 
          100, 173, 147, 2, 228, 84, 196, 195, 119, 103, 117, 129, 169, 81, 87, 
          154, 18, 75, 134, 231, 83, 174]}, 
        { :value=>[192, 186, 119, 13, 0, 0, 0, 0], :script=>[118, 169, 20, 128, 
          37, 178, 136, 203, 50, 93, 136, 188, 215, 239, 93, 26, 177, 248, 130, 
          119, 120, 213, 238, 136, 172]}]
      )
    end
  end

end

