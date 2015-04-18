require 'spec_helper'

# NOTE: Most of these examples are from: 
# https://github.com/CounterpartyXCP/counterpartyd/blob/master/docs/API.rst#id8
# The tests have to run in the specified order, as we populate our test account
# before running test operations
describe Counterparty do
  include_context 'globals'

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

    it "should persist asset send" do
      expect(subject.save!(source_privkey)).to_not be_empty
    end
  end

  describe "#do_issuance" do
    subject do
      Counterparty::Issuance.new source: source_address, asset: unique_asset_name, 
        quantity: 1000, description: "my asset is cool", divisible: true, 
        allow_unconfirmed_inputs: true
    end

    its(:to_raw_tx) { should_not be_empty }

    it "should persist issuance" do
      expect(subject.save!(source_privkey)).to_not be_empty
    end
  end

  describe "signed #create_broadcast" do
    subject do
      # We want the save(private_key) syntax here
      Counterparty::Broadcast.new source: source_address, fee_fraction: 0.05,
        text: "Price of gold, 12AM UTC March1. 1=inc 2=dec/const", value: 2.0,
        timestamp: Time.now.to_i, 
        allow_unconfirmed_inputs: true
    end

    its(:to_raw_tx) { should_not be_empty }

    it "should persist broadcast" do
      expect(subject.save!(source_privkey)).to_not be_empty
    end
  end

end
