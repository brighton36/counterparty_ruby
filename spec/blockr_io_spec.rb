require 'spec_helper'

# This is a fairly stand-alone test, and doesn't require much from the 
# helpers. 
describe BlockrIo do
  include_context 'globals'

  let(:blockr_main) { BlockrIo.new }
  let(:blockr_test) { BlockrIo.new true }

  describe "#new" do
    # It should default to the test network parameters
    subject{BlockrIo.new}

    its(:is_testing?){ should eq(false) }
  end

  context "testnet" do
    describe "#getrawtransaction" do
      it "should get raw testnet transactions" do
        tx_hash = '686c2e3c9d4b681b3589aa4ce2ba9ecb99c6d7dcbc1c754441ee0762f463f47a'

        expect(blockr_test.getrawtransaction(tx_hash)).to eq(
          '01000000017a2bf2ea931670ecb165f1f3a2586d9d2d338a50066d1096a3fc8e'+
          'b52e9667f8020000006a47304402201e92eebc6d9737472d085fc46f6ab45e8e'+
          'c6696ad3efb79261e5559ab0c517ac02200a905c54ebb9ac28e8402e6651ddf8'+
          'e067fa1305cd8c8685a40cb432bb7ef5f601210286b1e4f15de57fd34bde19cf'+
          '64ad9302e454c4c377677581a951579a124b86e7ffffffff03781e0000000000'+
          '0069512102a12853504fc4e79fea5e996f87e00e3e8e1d6a79c1e85c367e4ed4'+
          '4d4120f14521032247831fc423ee7c96a44fa088e64231b5f00cbc9fc755bf3b'+
          'dd41f64b80cbf9210286b1e4f15de57fd34bde19cf64ad9302e454c4c3776775'+
          '81a951579a124b86e753ae781e00000000000069512103852853504fc4e79fea'+
          '6fa406f7d61deeae390f1aee8b33580d3a98060111a18c2102502ee07ae44c88'+
          '5cf1cb23c4a4c67303f4bd2ce9cb8475f25aaf229e7aaeebb2210286b1e4f15d'+
          'e57fd34bde19cf64ad9302e454c4c377677581a951579a124b86e753aea0be00'+
          '00000000001976a9148025b288cb325d88bcd7ef5d1ab1f8827778d5ee88ac00'+
          '000000' )
      end
    end
  end

  context "mainnet" do
    describe "#getrawtransaction" do
      it "should retrieve the first burn" do
        tx_hash = '685623401c3f5e9d2eaaf0657a50454e56a270ee7630d409e98d3bc257560098'

        expect(blockr_main.getrawtransaction(tx_hash)).to eq(
          '010000000150326ab8ff04aa5bfd83f3dfc78b45716fd46864c872e2bd424fef'+
          'd580d5cf3e010000006b483045022100bf49d487f78345aa450c6f5fcb67a732'+
          '53d23cce1ae557f3edc6ed58a383f16a022032a4a4736b15bcf0d4c208cd8c5c'+
          'e43ced848ccc2b91acb82f4c87d95eb67a960121035bceeb417f25beaa28d133'+
          'ee7b28faa1e4f5c2f76b8daf12c3fab18261718790ffffffff0350c300000000'+
          '00001976a914818895f3dc2c178629d3d2d8fa3ec4a3f817982188ac00000000'+
          '00000000196a17434e5452505254590000003c50726f6f664f664275726e2030'+
          '0500000000001976a914f8195d523aa0c10d9d20eca785041815257f3ec888ac'+
          '00000000' )
      end

      it "should fail on bad transaction" do
        expect{blockr_main.getrawtransaction('bad_tx')}.to raise_error(RestClient::ResourceNotFound)
      end
    end
      
    describe "#listunspent" do
      it "should list unspent transactions" do
        unspents = blockr_main.listunspent('1CounterpartyXXXXXXXXXXXXXXXUWLpVr')

        expect(unspents.length).to eq(2620)
        expect(unspents.first.tap{|u| u.delete('confirmations') }).to eq( { 
          "tx"=>"bcd6fd6997d26ae12caef102f5e9631ee2ed1e38eaa16547a51d908f4c5ddac8", 
          "amount"=>"0.00005430", "n"=>0, 
          "script"=>"76a914818895f3dc2c178629d3d2d8fa3ec4a3f817982188ac"} )

      end
    end

    describe "#sendrawtransaction"  do
      # I think the way to test this is simply to do so in the resource_create
    end

  end
end
