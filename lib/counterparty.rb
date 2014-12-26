require 'json'
require 'rest_client'
require 'bitcoin'

require 'counterparty/version'
require 'counterparty/resource'
require 'counterparty/resources'
require 'counterparty/connection'

# The main module, under which all classes in the library are defined.
module Counterparty
  # One XCP, in units of Satoshi
  ONE_XCP = 100_000_000 
  
  # One BTC, in units of Satoshi
  ONE_BTC = 100_000_000 

  # This exception is typically raised by errors related to the params and/or
  # request format
  class JsonResponseError < StandardError; end

  # This exception comes from an error relating to a proper request, but an 
  # inability to complete the request via the counterpartyd api
  class ResponseError < StandardError
    attr_reader :data_type
    attr_reader :data_args
    attr_reader :data_message
    attr_reader :code
    attr_reader :message

    def initialize(json)
      @message, @code = json['message'], json['code']

      json['data'].each_pair do |(k,v)|
        instance_variable_set '@data_%s' % k, v
      end if json.has_key? 'data'

      super
    end
  end
  
  class << self
    # Sets/Gets the default connection object
    attr_writer :connection

    # Returns the current default connection object, or creates a new test-mode
    # connection, if none has been defined
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
