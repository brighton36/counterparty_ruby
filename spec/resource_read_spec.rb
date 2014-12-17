require 'spec_helper'

# NOTE: Most of these examples are from: 
# https://github.com/CounterpartyXCP/counterpartyd/blob/master/docs/API.rst#id8
describe Counterparty do
  before(:all) { Counterparty.production! }

 
  # Get all burns between blocks 280537 and 280539 where greater than .2 BTC was 
  # burned, sorting by tx_hash (ascending order) With this (and the rest of the 
  # examples below) we use positional arguments, instead of keyword-based arguments
  describe "#get_burns" do
    burn_params = {
        order_by: 'tx_hash', 
        order_dir: 'asc', 
        start_block: 280537, 
        end_block: 280539 }

    subject{ Counterparty::Burn.find burn_params }

    it("should equal get_burns") do
      expect(subject).to eq(Counterparty.connection.get_burns(burn_params))
    end

    its('length'){ should eq(10) }
    its('first') do
      should eq(Counterparty::Burn.new( 
        tx_index: 1096, 
        source: '1ADpYypUcnbezuuYpCyRCY7G4KD6a9YXiF', 
        block_index: 280537, 
        earned: 129754545455, 
        status: "valid",
        burned: 100000000, 
        tx_hash: '6e905ec73870d6c6cdc8f4e64767ec41f74c8f07a24cc7c54811134f5b6aa6a7' 
        ) )
    end
  end
  
  # Fetch all balances for all assets for both of two addresses, using keyword-
  # based arguments
  describe "#get_balances" do
    balance_params = { filters: { 
      field: 'address', op: '==', value: "14qqz8xpzzEtj6zLs3M1iASP7T4mj687yq" } }

    subject{ Counterparty::Balance.find balance_params }

    it("should equal get_balances") do
      expect(subject).to eq(Counterparty.connection.get_balances(balance_params))
    end

    its('length'){ should eq(1) }
    its('first') do
      should eq(Counterparty::Balance.new(
        quantity: 0, 
        asset: "XCP", 
        address: "14qqz8xpzzEtj6zLs3M1iASP7T4mj687yq" ) )
    end
  end

  # Fetch all debits for > 2 XCP between blocks 280537 and 280539, sorting the 
  # results by quantity (descending order)
  describe "#get_debits" do
    debit_params = {
      filters: [
          {field: 'asset', op: '==', value: "XCP"},
          {field: 'quantity', op: '>', value: 200000000} 
          ],
      filterop: 'AND',
      order_by: 'quantity',
      order_dir: 'desc'}

    subject{ Counterparty::Debit.find debit_params }

    it("should equal get_debits") do
      expect(subject).to eq(Counterparty.connection.get_debits(debit_params))
    end

    its('length'){ should eq(1000) }
    its('first') do
      should eq(Counterparty::Debit.new(
        block_index: 318845,
        asset: "XCP",
        address: "1FxhdSid1TUfzfTyveMcsUhF3ePjRK6qqa",
        action: "send",
        event: "64c26f4dc12fbbdbead62962a9428d4a6b17a44c061d202ff525e2f513cd34e8",
        quantity: 6184957374430
      ) )
    end
  end

  describe "#get_credits" do
    pending
  end

  describe "#get_debits" do
    pending
  end
 
  describe "#get_bets" do
    # pending
  end
  
  describe "#get_bet_matches" do
    # pending
  end
  
  describe "#get_broadcasts" do
    # You get the idea...
  end
  
  describe "#get_btcpays" do
  end
  
  describe "#get_burns" do
  end
  
  describe "#get_callbacks" do
  end
  
  describe "#get_cancels" do
  end
  
  describe "#get_dividends" do
  end
  
  describe "#get_issuances" do
  end
  
  describe "#get_orders" do
  end
  
  describe "#get_order_matches" do
  end
  
  describe "#get_sends" do
  end
  
  describe "#get_bet_expirations" do
  end
  
  describe "#get_order_expirations" do
  end
  
  describe "#get_bet_match_expirations" do
  end
  
  describe "#get_order_match_expirations" do
  end
  
  describe "#get_rps" do
  end
  
  describe "#get_rps_expirations" do
  end
  
  describe "#get_rps_matches" do
  end
  
  describe "#get_rps_match_expirations" do
  end
  
  describe "#get_rpsresolves" do
  end

end
