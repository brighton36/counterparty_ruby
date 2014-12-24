require 'spec_helper'

describe Bitcoin::Client do
  describe "Bitcoin client works the way we think" do
    subject{ bitcoin}

    its(:host){should eq('localhost')}
    its(:port){should eq(18332)}
    its(:user){should eq('rpc')}
    its(:pass){should eq('A4Xd7AQE4XIw0h')}

    its(:getblockcount){should be_a_kind_of(Numeric)}
  end
end
