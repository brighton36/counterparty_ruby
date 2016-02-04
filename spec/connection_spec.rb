require 'spec_helper'

describe Counterparty::Connection do
  describe "#new" do
    # It should default to the test network parameters
    subject{Counterparty::Connection.new}

    its(:host){ should eq('public.coindaddy.io') }
    its(:port){ should eq(14000) }
    its(:username){ should eq('rpc') }
    its(:password){ should eq('1234') }
    its(:api_url){ should eq('http://rpc:1234@public.coindaddy.io:14000/api/') }
  end
end
