require 'spec_helper'

describe Bitcoin::Client do
  let(:bitcoin_test){ Bitcoin::Client.new 'rpc', 'A4Xd7AQE4XIw0h', 
    :host => 'localhost', :port => 18332 }

  describe "Bitcoin client works the way we think" do
    subject{ bitcoin_test }

    its(:host){should eq('localhost')}
    its(:port){should eq(18332)}
    its(:user){should eq('rpc')}
    its(:pass){should eq('A4Xd7AQE4XIw0h')}

    its(:getblockcount){should be_a_kind_of(Numeric)}
  end
end
