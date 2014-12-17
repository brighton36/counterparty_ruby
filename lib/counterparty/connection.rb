module Counterparty

  class JsonResponseError < StandardError; end
  class ResponseError < StandardError; end

  
  # This class connects to the api. Mostly it's not intended for use by library
  # consumers, but there are some helper methods in here for those that prefer 
  # the Connection.get_burns syntax instead of the Counterparty::Burn.find syntax
  class Connection
    attr_accessor :host, :port, :username, :password

    def initialize(port=14000, username='rpc', password='1234', host='localhost')
      @host,@port,@username,@password=host.to_s,port.to_i,username.to_s,password.to_s
    end

    # The url being connected to for the purpose of an api call
    def api_url
      'http://%s:%s@%s:%s/api/' % [@username,@password,@host,@port.to_s]
    end

    def request(method, params)
      response = JSON.parse RestClient.post(api_url, { method: method, 
        params: params, jsonrpc: '2.0', id: '0' }.to_json,
        user: @username, password: @password, accept: 'json', 
        content_type: 'json' )

      # TODO: Make this work? Test perhaps?
      raise JsonResponseError.new response if response.has_key? 'code'
      raise ResponseError.new response['error'] if response.has_key? 'error'

      puts "Here:"+response.inspect

      response['result']
    end

  end
end
