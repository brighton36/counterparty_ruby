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

    def resource_request(klass)
      define_method(klass.to_get_request){ |params| klass.find params }

      # TODO: Add the creates?
    end

    # Go ahead and setup the defined resources, and throw them into the native-style
    # api methods:
    constants.each do |klass|
      resource_request klass if klass.kind_of? CounterResource
    end

  end
end
