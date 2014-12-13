require 'counterparty/version'
require 'json'
require 'rest_client'

module Counterparty
  class Client
    attr_accessor :host, :port, :username, :password

    def initialize(host='localhost', port=4000, username='rpc', password='1234')
      @host,@port,@username,@password=host.to_s,port.to_i,username.to_s,password.to_s
    end

    def get_burns(params)
      request 'get_burns', params
    end

    def api_url
      ['http://',@host,':',@port.to_s,'/api/'].join
    end

    private

    def request(method, params)
      JSON.parse RestClient::Request.execute( method: :post, url: api_url,
        user: @username, password: @password,
        headers: { accept: 'json', content_type: 'json' },
        data: { method: method, params: params, jsonrpc: '2.0', 
          id: '0' }.to_json 
      ).to_str
    end

  end
end
