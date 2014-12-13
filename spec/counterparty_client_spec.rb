require 'spec_helper'

describe Counterparty::Client do
  let(:default_cp) { Counterparty::Client.new }

  describe "#new" do
    subject{default_cp}

    its(:host){ should eq('localhost') }
    its(:port){ should eq(4000) }
    its(:username){ should eq('rpc') }
    its(:password){ should eq('1234') }
    its(:api_url){ should eq('http://localhost:4000/api/') }
  end

  describe "#get_burns" do
    it "what happens" do
      ret = default_cp.get_burns( order_by: 'tx_hash', order_dir: 'asc', 
        start_block: 280537, end_block: 280539 )
      puts ret.inspect
    end
    #subject{@cp.get_burns( order_by: 'tx_hash', order_dir: 'asc', 
      #start_block: 280537, end_block: 280539 )}

  end
  
end
