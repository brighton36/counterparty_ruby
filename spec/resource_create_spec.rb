require 'spec_helper'

# NOTE: Most of these examples are from: 
# https://github.com/CounterpartyXCP/counterpartyd/blob/master/docs/API.rst#id8
# The tests have to run in the specified order, as we populate our test account
# before running test operations
describe Counterparty do
  # TODO: Put this in a spec config?
  let(:test_address){ "msCXwsPVbv1Q1pc5AjXd5TdVwy3a1fSYB2" }
  let(:bitcoin_test){ Bitcoin::Client.new 'rpc', 'A4Xd7AQE4XIw0h', 
    :host => 'localhost', :port => 18332 }
  let(:tp_faucet){ "msj42CCGruhRsFrGATiUuh25dtxYtnpbTx" }

  before(:all) { Counterparty.test! }

  it "Ensure test account has BTC" do
    expect(bitcoin_test.getreceivedbyaddress(test_address)).to be > 0
  end

  describe "Ensure test account has XCP" do
    subject do
      Counterparty::Balance.find( filters: 
        { field: 'address', op: '==', value: test_address} 
      ).find{|b| b.asset == 'XCP' }
    end

    its(:quantity){ should be > Counterparty::ONE_XCP }
  end

  describe "Burn some XCP into the test address" do
    pending
  end

  # Send 1 XCP (specified in satoshis) from one address to another (you must have 
  # the sending address in your bitcoind wallet and it will be broadcast as a 
  # multisig transaction
  describe "#do_send" do
    subject{ Counterparty::Send.new source: test_address, destination: tp_faucet, 
      asset: "XCP", quantity: Counterparty::ONE_XCP }

    its(:to_raw_tx) { should_not be_empty }
    its(:save!) { should_not be_empty }
  end

  describe "#do_issuance" do
    pending  
  end

  describe "Errors on bad parameter" do
    pending
  end

end
