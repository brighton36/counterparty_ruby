require 'counterparty/version'
require 'json'
require 'rest_client'

module Counterparty
  class JsonResponseError < StandardError; end

  # A base class for the purpose of extending by api result hashes
  class ResultClass
    attr_accessor :result_attributes

    def initialize(attrs)
      @result_attrs = attrs.keys.sort
      attrs.each{|k,v| instance_variable_set '@%s' % k, v}
    end

    def ==(b)
      ( result_attributes == b.result_attributes && 
      @result_attrs.all?{ |k| send(k) == b.send(k) } )
    end
  end

  # This is returned via get_burns, and represents a Burn transaction
  class Burn < ResultClass; 
    attr_accessor :tx_index, :source, :block_index, :earned, :status, 
      :burned, :tx_hash
  end

  # This class connects to the api
  class Client
    attr_accessor :host, :port, :username, :password

    def initialize(host='localhost', port=4000, username='rpc', password='1234')
      @host,@port,@username,@password=host.to_s,port.to_i,username.to_s,password.to_s
    end

    # Returns transactions from the burn.
    def get_burns(params)
      request('get_burns', params).collect{|b| Burn.new b}
    end

    # The url being connected to for the purpose of an api call
    def api_url
      'http://%s:%s@%s:%s/api/' % [@username,@password,@host,@port.to_s,'/api/']
    end

    private

    def request(method, params)
      response = JSON.parse RestClient.post(api_url, { method: method, 
        params: params, jsonrpc: '2.0', id: '0' }.to_json,
        user: @username, password: @password, accept: 'json', 
        content_type: 'json' )

      # TODO: Make this work? Test perhaps?
      raise JsonResponseError.new response if response['code'] 

      response['result']
    end

  end
end
