module Counterparty

  class JsonResponseError < StandardError; end

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
  
  # This class connects to the api. Mostly it's not intended for use by library
  # consumers, but there are some helper methods in here for those that prefer 
  # the Connection.get_burns syntax instead of the Counterparty::Burn.find syntax
  class Connection
    DEFAULT_TIMEOUT = -1

    attr_accessor :host, :port, :username, :password

    attr_writer :timeout

    def initialize(port=14000, username='rpc', password='1234', host='localhost')
      @host,@port,@username,@password=host.to_s,port.to_i,username.to_s,password.to_s
      @timeout = DEFAULT_TIMEOUT
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
      client = RestClient::Resource.new api_url, :timeout => @timeout
      response = JSON.parse client.post({ method: method, 
        params: params, jsonrpc: '2.0', id: '0' }.to_json,
        user: @username, password: @password, accept: 'json', 
        content_type: 'json' )

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
