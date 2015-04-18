require 'spec_helper'

# This is a fairly stand-alone test, and doesn't require much from the 
# helpers. 
describe BlockrIo do
  include_context 'globals'

  let(:blockr_main) { BlockrIo.new }

  describe "#new" do
    # It should default to the test network parameters
    subject{BlockrIo.new}

    its(:is_testing?){ should eq(false) }
  end

  context "mainnet" do
    describe "#gettransaction" do
      it "should retrieve the first burn" do
        tx = blockr_main.gettransaction(
          '685623401c3f5e9d2eaaf0657a50454e56a270ee7630d409e98d3bc257560098')

        # This changes all the time, so we nix it:
        tx.delete 'confirmations'

        expect(tx).to eq({ 
          "tx"=>"685623401c3f5e9d2eaaf0657a50454e56a270ee7630d409e98d3bc257560098", 
          "block"=>278319, "time_utc"=>"2014-01-02T22:19:37Z", 
          "is_coinbased"=>0, "trade"=>{"vins"=>[
            {"address"=>"1Pcpxw6wJwXABhjCspe3CNf3gqSeh6eien", "is_nonstandard"=>false, 
            "amount"=>-0.0006, "n"=>1, "type"=>0, 
            "vout_tx"=>"3ecfd580d5ef4f42bde272c86468d46f71458bc7dff383fd5baa04ffb86a3250"}], 
          "vouts"=>[{"address"=>"1CounterpartyXXXXXXXXXXXXXXXUWLpVr", 
            "is_nonstandard"=>false, "amount"=>0.0005, "n"=>0, "type"=>1, "is_spent"=>0}, {"address"=>"NONSTANDARD", "is_nonstandard"=>true, "amount"=>0, "n"=>1, "type"=>2, 
            "is_spent"=>0}]}, 
          "vins"=>[{"address"=>"1Pcpxw6wJwXABhjCspe3CNf3gqSeh6eien", 
            "is_nonstandard"=>false, "amount"=>"-0.00400000", "n"=>1, "type"=>0, 
            "vout_tx"=>"3ecfd580d5ef4f42bde272c86468d46f71458bc7dff383fd5baa04ffb86a3250"}], 
          "vouts"=>[{"address"=>"1CounterpartyXXXXXXXXXXXXXXXUWLpVr", 
            "is_nonstandard"=>false, "amount"=>"0.00050000", "n"=>0, "type"=>1, 
            "is_spent"=>0, "extras"=>{
              "asm"=>"OP_DUP OP_HASH160 818895f3dc2c178629d3d2d8fa3ec4a3f8179821 OP_EQUALVERIFY OP_CHECKSIG", "script"=>"76a914818895f3dc2c178629d3d2d8fa3ec4a3f817982188ac", 
              "reqSigs"=>1, "type"=>"pubkeyhash"}}, {"address"=>"NONSTANDARD", 
            "is_nonstandard"=>true, "amount"=>"0.00000000", "n"=>1, "type"=>2, 
            "is_spent"=>0, "extras"=>{
              "asm"=>"OP_RETURN 434e5452505254590000003c50726f6f664f664275726e", 
              "script"=>"6a17434e5452505254590000003c50726f6f664f664275726e", 
              "reqSigs"=>0, "type"=>"nonstandard"}}, 
            {"address"=>"1Pcpxw6wJwXABhjCspe3CNf3gqSeh6eien", "is_nonstandard"=>false, 
              "amount"=>"0.00340000", "n"=>2, "type"=>1, "is_spent"=>1}], 
            "fee"=>"0.00010000", "days_destroyed"=>"0.01", "is_unconfirmed"=>false, 
            "extras"=>nil})
      end

      it "should fail on bad transaction" do
        expect{blockr_main.gettransaction('bad_tx')}.to raise_error(RestClient::ResourceNotFound)
      end
    end
      
    describe "#sendrawtransaction"  do
      pending
    end
  end

  context "testnet" do
    pending
  end
end
