require 'json'
require 'rest_client'
require 'counterparty/version'
require 'counterparty/resources'
require 'counterparty/connection'

module Counterparty

  class JsonResponseError < StandardError; end

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
