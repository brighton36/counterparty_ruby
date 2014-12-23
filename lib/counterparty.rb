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
  
  # One BTC, in units of Satoshi
  ONE_BTC = 100_000_000 

  class << self
    # Sets/Gets the default connection object
    attr_writer :connection

    def connection
      @connection || Connection.new
    end

    # Establishes the default connection for new objects as being the default 
    # counterparty production mode port/user/ip
    def production!
      @connection = Connection.new 4000
    end

    # Establishes the default connection for new objects as being the default 
    # counterparty test mode port/user/ip
    def test!
      @connection = Connection.new
    end
  end
end
