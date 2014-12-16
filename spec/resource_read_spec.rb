require 'spec_helper'

describe Counterparty do
  before(:all) do
    Counterparty.production!
  end

  # NOTE: Most of these examples are from: 
  # https://github.com/CounterpartyXCP/counterpartyd/blob/master/docs/API.rst#id8
 
  describe Counterparty::Burn do
    subject do
      Counterparty::Burn.find(
        order_by: 'tx_hash', 
        order_dir: 'asc', 
        start_block: 280537, 
        end_block: 280539 )
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
  
  describe "#get_balances" do
    subject do 
      Counterparty::Balance.find( filters: { field: 'address', op: '==', 
        value: "14qqz8xpzzEtj6zLs3M1iASP7T4mj687yq" } )
    end

    its('length'){ should eq(1) }
    its('first') do
      should eq(Counterparty::Balance.new(
        quantity: 0, 
        asset: "XCP", 
        address: "14qqz8xpzzEtj6zLs3M1iASP7T4mj687yq" ) )
    end
  end

  describe "#get_debits" do
    subject do 
      Counterparty::Debit.find( filters: [
          {field: 'asset', op: '==', value: "XCP"},
          {field: 'quantity', op: '>', value: 200000000} 
          ],
        filterop: 'AND',
        order_by: 'quantity',
        order_dir: 'desc')
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
  end
  
  describe "#get_bet_matches" do
  end
  
  describe "#get_broadcasts" do
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
