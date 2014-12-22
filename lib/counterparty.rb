require 'json'
require 'rest_client'
require 'bitcoin-client'
require 'counterparty/version'
require 'counterparty/resource'
require 'counterparty/resources'
require 'counterparty/connection'

module Counterparty
  # One XCP, in units of Satoshi
  ONE_XCP = 100_000_000 
  ONE_BTC = 100_000_000 

  class << self
    # There is no default password, so really all this acheives is the prevention
    # of .bitcoin being nil
    BTC_TESTNET = ['rpc', 'password', :host => 'localhost', :port => 18333 ]

    attr_writer :connection
    attr_writer :bitcoin

    def connection
      @connection || Connection.new
    end

    def production!
      @connection = Connection.new 4000
    end

    def test!
      @connection = Connection.new
    end
  end
end
