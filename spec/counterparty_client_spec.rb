require 'spec_helper'

describe Counterparty::Client do
  let(:default_cp) { Counterparty::Client.new }

  describe "#new" do
    subject{default_cp}

    its(:host){ should be('localhost') }
    its(:port){ should be(4000) }
    its(:username){ should be('rpc') }
    its(:password){ should be('1234') }
  end

  describe "#get_burns" do
    subject{@cp.get_burns( order_by: 'tx_hash', order_dir: 'asc', 
      start_block: 280537, end_block: 280539 )}

  end
  
end
