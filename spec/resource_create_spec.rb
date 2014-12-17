require 'spec_helper'

# NOTE: Most of these examples are from: 
# https://github.com/CounterpartyXCP/counterpartyd/blob/master/docs/API.rst#id8
# The tests have to run in the specified order, as we populate our test account
# before running test operations
describe Counterparty do
  let(:test_address){ "msCXwsPVbv1Q1pc5AjXd5TdVwy3a1fSYB2" }

  before(:all) { Counterparty.test! }

  describe "Ensure test account has BTC" do
    # BlockExplorer.getreceivedbyaddress(address)
    # TODO
  end

  describe "Ensure test account has XCP" do
    subject do
      Counterparty::Balance.find( filters: 
        { field: 'address', op: '==', value: test_address} 
      ).find{|b| b.asset == 'XCP' }
    end

    its(:quantity){ should be > Counterparty::ONE_XCP }
  end

  # Send 1 XCP (specified in satoshis) from one address to another (you must have 
  # the sending address in your bitcoind wallet and it will be broadcast as a 
  # multisig transaction
  describe "#create_send" do
    let(:send_params) { {
      source: test_address,
      destination: "msj42CCGruhRsFrGATiUuh25dtxYtnpbTx",
      asset: "XCP",
      quantity: Counterparty::ONE_XCP } }

    subject{ Counterparty::Send.new send_params }

    # TODO: Test the Counterparty.create_send method

    its(:save!) { should eq('aoeuau') }

  end

  # TODO: Test the error raisings

end
