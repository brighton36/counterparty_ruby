require 'json'
require 'rest_client'
require 'counterparty/version'
require 'counterparty/resource'
require 'counterparty/resources'
require 'counterparty/connection'

module Counterparty

  # One XCP, in units of Satoshi
  ONE_XCP = 100000000 

  class << self
    attr_accessor :connection

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
