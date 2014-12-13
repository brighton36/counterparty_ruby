require 'spec_helper'

describe Counterparty::Client do
  let(:default_cp) { Counterparty::Client.new }

  describe "#new" do
    subject{default_cp}

    its(:host){ should eq('localhost') }
    its(:port){ should eq(4000) }
    its(:username){ should eq('rpc') }
    its(:password){ should eq('1234') }
    its(:api_url){ should eq('http://rpc:1234@localhost:4000/api/') }
  end

  describe "#get_burns" do
    subject{default_cp.get_burns( order_by: 'tx_hash', order_dir: 'asc', 
      start_block: 280537, end_block: 280539 )}
    its('length'){ should eq(10) }
    its('first') do
      should eq(Counterparty::Burn.new( tx_index: 1096, 
      source: '1ADpYypUcnbezuuYpCyRCY7G4KD6a9YXiF', block_index: 280537, 
        earned: 129754545455, status: "valid", burned: 100000000, 
        tx_hash: '6e905ec73870d6c6cdc8f4e64767ec41f74c8f07a24cc7c54811134f5b6aa6a7' 
      ) )
    end
  end
  
end
