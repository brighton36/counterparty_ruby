require 'spec_helper'

describe Counterparty::Client do
  let(:default_cp) { Counterparty::Client.new }

  # NOTE: Most of these examples are from: 
  # https://github.com/CounterpartyXCP/counterpartyd/blob/master/docs/API.rst#id8
 
  describe "#new" do
    subject{default_cp}

    its(:host){ should eq('localhost') }
    its(:port){ should eq(4000) }
    its(:username){ should eq('rpc') }
    its(:password){ should eq('1234') }
    its(:api_url){ should eq('http://rpc:1234@localhost:4000/api/') }
  end
end
