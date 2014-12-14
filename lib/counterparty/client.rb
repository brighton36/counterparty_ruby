module Counterparty
  # This class connects to the api
  class Client
    attr_accessor :host, :port, :username, :password

    def initialize(host='localhost', port=4000, username='rpc', password='1234')
      @host,@port,@username,@password=host.to_s,port.to_i,username.to_s,password.to_s
    end

    def self.read_request(klass)
      define_method(klass.to_get_request) do |params|
        request(klass.to_get_request, params).collect{|r| klass.new r}
      end
    end

    include Counterparty::ReadRequests

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
