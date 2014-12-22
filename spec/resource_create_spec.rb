require 'spec_helper'

# NOTE: Most of these examples are from: 
# https://github.com/CounterpartyXCP/counterpartyd/blob/master/docs/API.rst#id8
# The tests have to run in the specified order, as we populate our test account
# before running test operations
describe Counterparty do
  # TODO: Put this in a spec config?
  let(:source_address){ "msCXwsPVbv1Q1pc5AjXd5TdVwy3a1fSYB2" }
  let(:bitcoin_test){ Bitcoin::Client.new 'rpc', 'A4Xd7AQE4XIw0h', 
    :host => 'localhost', :port => 18332 }
  let(:tp_faucet){ "msj42CCGruhRsFrGATiUuh25dtxYtnpbTx" }

  before(:all) { Counterparty.test! }

  it "Ensure test account has BTC" do
    expect(bitcoin_test.getreceivedbyaddress(source_address)).to be > 0
  end

  describe "Ensure test account has XCP" do
    subject do
      Counterparty::Balance.find( filters: 
        { field: 'address', op: '==', value: source_address} 
      ).find{|b| b.asset == 'XCP' }
    end

    its(:quantity){ should be > Counterparty::ONE_XCP }
  end

# I'm commenting this out for now, as this test is impractical
=begin
  describe "#do_burn" do
    subject do 
      Counterparty::Burn.new source: source_address, 
        quantity: Counterparty::ONE_BTC
    end

    its(:to_raw_tx) { should_not be_empty }
    its(:save!) { should_not be_empty }
  end
=end

  # Send 1 XCP (specified in satoshis) from one address to another (you must have 
  # the sending address in your bitcoind wallet and it will be broadcast as a 
  # multisig transaction
  describe "#do_send" do
    subject do 
      Counterparty::Send.new source: source_address, destination: tp_faucet, 
        asset: "XCP", quantity: Counterparty::ONE_XCP, 
        allow_unconfirmed_inputs: true
    end

    its(:to_raw_tx) { should_not be_empty }
    its(:save!) { should_not be_empty }
  end

  describe "#do_issuance" do
    subject do
      # Since asset names have to be unique, we try our best to create a unique
      # one here. This asset is composed of the timestamp, plus the machine
      # name we're running on. Be advised this might be a small privacy breach 
      # forsensitive operations.
      # There might be some collisions here due to my not handling fixed-width
      # integers greater than 26. I don't think I care about that right now
      base26_time = Time.now.strftime('%y %m %d %H %M %S').split(' ').collect{|c| c.to_i.to_s(26)}
      alpha_encode = base26_time.join.tr((('0'..'9').to_a+('a'..'q').to_a).join, ('A'..'Z').to_a.join)

      asset_name = [alpha_encode,`hostname`.upcase.tr('^A-Z','')].join[0...12]

      Counterparty::Issuance.new source: source_address,
        asset: asset_name, quantity: 1000, description: "my asset is cool",
        callable: true, call_date: 1418926641, call_price: 100000000,
        divisible: true,
        allow_unconfirmed_inputs: true
    end

    its(:to_raw_tx) { should_not be_empty }
    its(:save!) { should_not be_empty }
  end

  describe Counterparty::ResponseError do
    let(:bad_issuance) do
      Counterparty::Issuance.new source: source_address,
        asset: 'THISASSETNAMEISFARTOOLONGANDINVALID', 
        quantity: 1000, description: "my asset is uncool",
        allow_unconfirmed_inputs: true
    end

    it "should fail on to_raw_tx" do
      expect{ bad_issuance.to_raw_tx }.to raise_error Counterparty::ResponseError
    end

    it "should fail on save!" do
      expect{ bad_issuance.save! }.to raise_error Counterparty::ResponseError
    end

    subject do
      begin
        bad_issuance.save!
      rescue => error
        error
      end
    end

    its(:data_type) { should eq('AssetNameError') }
    its(:data_args) { should eq(["long asset names must be numeric"]) }
    its(:data_message) { should eq("long asset names must be numeric") }
    its(:code) { should eq(-32000) }
    its(:message) { should eq("Server error") }
  end

  describe Counterparty::JsonResponseError do
    pending
  end
end
