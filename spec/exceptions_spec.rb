require 'spec_helper'

describe Counterparty::ResponseError do
  include_context 'globals'

  before(:all) do
    Counterparty.test!
    Counterparty.connection = local_counterpartyd :test if use_local_counterpartyd?
  end

  let(:bad_issuance) do
    Counterparty::Issuance.new source: source_address,
      asset: 'THISASSETNAMEISFARTOOLONGANDINVALID', 
      quantity: 1000, description: "my asset is uncool",
      allow_unconfirmed_inputs: true
  end

  it "should fail on to_raw_tx" do
    expect{ bad_issuance.to_raw_tx }.to raise_error Counterparty::ResponseError
  end

  it "should fail on save!" do
    expect{ bad_issuance.save!(source_privkey) }.to raise_error Counterparty::ResponseError
  end

  subject do
    begin
      bad_issuance.save!(source_privkey)
    rescue => error
      error
    end
  end

  its(:data_type) { should eq('AssetNameError') }
  its(:data_args) { should eq(["long asset names must be numeric"]) }
  its(:data_message) { should eq("long asset names must be numeric") }
  its(:code) { should eq(-32000) }
  its(:message) { should eq("Server error: long asset names must be numeric") }
end

describe Counterparty::JsonResponseError do
  pending
end
