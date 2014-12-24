$:<< File.join(File.dirname(__FILE__), '..','lib')

require 'rspec/its'
require 'bitcoin-client'
require 'counterparty'

BTC_CONNECTION = ['rpc', 'A4Xd7AQE4XIw0h', :host => 'localhost', :port => 18332 ]
SOURCE_ADDRESS = "msCXwsPVbv1Q1pc5AjXd5TdVwy3a1fSYB2" 
SOURCE_PRIVKEY = "cP7ufwcbZujaa1qkKthLbVZUaP88RS5r9awyXerJE5rAEMTRVmzc"
DESTINATION_ADDRESS = "msj42CCGruhRsFrGATiUuh25dtxYtnpbTx"

def source_address
  SOURCE_ADDRESS
end

def source_privkey
  SOURCE_PRIVKEY
end

def bitcoin
  Bitcoin::Client.new *BTC_CONNECTION
end

def destination_address
  DESTINATION_ADDRESS
end

# Since asset names have to be unique, we try our best to create a unique
# one here. This asset is composed of the timestamp, plus the machine
# name we're running on. Be advised this might be a small privacy breach 
# forsensitive operations.
# There might be some collisions here due to my not handling fixed-width
# integers greater than 26. I don't think I care about that right now
def unique_asset_name
  base26_time = Time.now.strftime('%y %m %d %H %M %S').split(' ').collect{|c| c.to_i.to_s(26)}
  alpha_encode = base26_time.join.tr((('0'..'9').to_a+('a'..'q').to_a).join, ('A'..'Z').to_a.join)

  [alpha_encode,`hostname`.upcase.tr('^A-Z','')].join[0...12]
end
