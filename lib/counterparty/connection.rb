module Counterparty
  # This class connects to the Counterparty api. Mostly it's not intended for 
  # use by library consumers, but there are some helper methods in here for 
  # those that prefer the Connection.get_burns syntax instead of the 
  # Counterparty::Burn.find syntax
  class Connection
    # The default connection timeout, nil is "no timeout"
    DEFAULT_TIMEOUT = nil

    attr_accessor :host, :port, :username, :password

    # A response timeout threshold By default, this initializes to -1, 
    # which means the library will wait indefinitely before timing out
    attr_writer :timeout

    def initialize(port=4000, username='counterparty', password='1234', host='xcp-dev.vennd.io')
      @host,@port,@username,@password=host.to_s,port.to_i,username.to_s,password.to_s
      @timeout = DEFAULT_TIMEOUT
    end

    # The url being connected to for the purpose of an api call
    def api_url
      'http://%s:%s@%s:%s/api/' % [@username,@password,@host,@port.to_s]
    end

    # Returns a signed raw transaction, given a private key
    def sign_tx(raw_tx, private_key)
      request 'sign_tx', unsigned_tx_hex: raw_tx, privkey: private_key
    end

    # Issue a request to the counterpartyd server for the given method, with the 
    # given params.
    def request(method, params)
      client = RestClient::Resource.new api_url, :timeout => @timeout
      request = { method: method, params: params, jsonrpc: '2.0', id: '0' }.to_json
      response = JSON.parse client.post(request,
        user: @username, password: @password, accept: 'json', 
        content_type: 'json' )

      raise JsonResponseError.new response if response.has_key? 'code'
      raise ResponseError.new response['error'] if response.has_key? 'error'

      response['result']
    end

    # This creates the legacy api-format request methods on the connection
    # argument. It lets us be relatively introspective about how we do this so
    # as to be future-proof here going forward
    def self.resource_request(klass) # :nodoc:
      define_method(klass.to_get_request){ |params| klass.find params }
      define_method(klass.to_create_request){ |params| klass.create(params).to_raw_tx }
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
