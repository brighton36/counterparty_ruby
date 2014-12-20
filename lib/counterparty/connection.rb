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

    # Returns a signed raw transaction, given a private key
    def sign_tx(raw_tx, private_key)
      # TODO
    end

    # Broadcasts a signed transaction onto the bitcoin blockchain
    def broadcast_tx(signed_tx)
      # TODO
    end

    def request(method, params)
      response = JSON.parse RestClient.post(api_url, { method: method, 
        params: params, jsonrpc: '2.0', id: '0' }.to_json,
        user: @username, password: @password, accept: 'json', 
        content_type: 'json' )

      # TODO: Make this work? Test perhaps?
      raise JsonResponseError.new response if response.has_key? 'code'
      raise ResponseError.new response['error'] if response.has_key? 'error'

      response['result']
    end

    def self.resource_request(klass)
      define_method(klass.to_get_request){ |params| klass.find params }

      # TODO: Add the creates?
    end

    # Go ahead and setup the defined resources, and throw them into the native-style
    # api methods:
    Counterparty.constants.each do |c| 
      begin
        klass = Counterparty.const_get(c)
        if klass.respond_to?(:api_name) && klass != Counterparty::CounterResource
          self.resource_request klass 
        end
      rescue NameError
        next
      end
    end

  end
end
