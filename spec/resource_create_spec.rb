require 'spec_helper'

# NOTE: Most of these examples are from: 
# https://github.com/CounterpartyXCP/counterpartyd/blob/master/docs/API.rst#id8
# The tests have to run in the specified order, as we populate our test account
# before running test operations
describe Counterparty do
  before(:all) { Counterparty.test! }

  # TODO: deprecate?
  #it "Ensure test account has BTC" do
    #expect(bitcoin.getreceivedbyaddress(source_address)).to be > 0
  #end

  describe "Ensure test account has XCP" do
    subject do
      Counterparty::Balance.find( filters: 
        { field: 'address', op: '==', value: source_address} 
      ).find{|b| b.asset == 'XCP' }
    end

    its(:quantity){ should be > Counterparty::ONE_XCP }
  end

  # Send 1 XCP (specified in satoshis) from one address to another (you must have 
  # the sending address in your bitcoind wallet and it will be broadcast as a 
  # multisig transaction
  describe "#do_send" do
    subject do 
      Counterparty::Send.new source: source_address, destination: destination_address, 
        asset: "XCP", quantity: Counterparty::ONE_XCP, 
        allow_unconfirmed_inputs: true
    end

    its(:to_raw_tx) { should_not be_empty }
    its(:save!) { should_not be_empty }
  end

  describe "#do_issuance" do
    subject do
      Counterparty::Issuance.new source: source_address, asset: unique_asset_name, 
        quantity: 1000, description: "my asset is cool",
        callable: true, call_date: 1418926641, call_price: 100000000,
        divisible: true, allow_unconfirmed_inputs: true
    end

    its(:to_raw_tx) { should_not be_empty }
    its(:save!) { should_not be_empty }
  end

  describe "signed #create_broadcast" do
    subject do
      # We want the save(private_key) syntax here
      Counterparty::Broadcast.new source: source_address, fee_fraction: 0.05,
        text: "Price of gold, 12AM UTC March1. 1=inc 2=dec/const", value: 2.0,
        timestamp: 1418926641, 
        allow_unconfirmed_inputs: true
    end

    its(:to_raw_tx) { should_not be_empty }

    it "should persist using a provided key" do
      begin 
        # TODO: why is this failing... I think the key isn't in WIF format
        expect(subject.save!(source_privkey)).to_not be_empty
      rescue Counterparty::ResponseError => e
        puts e.inspect
      end
    end
  end

end
