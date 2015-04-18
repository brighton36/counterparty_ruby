require 'spec_helper'

describe Counterparty::Connection do
  describe "#new" do
    # It should default to the test network parameters
    subject{Counterparty::Connection.new}

    its(:host){ should eq('xcp-dev.vennd.io') }
    its(:port){ should eq(4000) }
    its(:username){ should eq('counterparty') }
    its(:password){ should eq('1234') }
    its(:api_url){ should eq('http://counterparty:1234@xcp-dev.vennd.io:4000/api/') }
  end
end
