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
      request 'sign_tx', unsigned_tx_hex: raw_tx, privkey: private_key
    end

    # Broadcasts a signed transaction onto the bitcoin blockchain
    def broadcast_tx(signed_tx)
      request 'broadcast_tx', signed_tx_hex: signed_tx
    end

    # Issue a request to the counterpartyd server for the given method, with the 
    # given params.
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

    # This creates the legacy api-format request methods on the connection
    # argument. It lets us be relatively introspective about how we do this so
    # as to be future-proof here going forward
    def self.resource_request(klass) # :nodoc:
      define_method(klass.to_get_request){ |params| klass.find params }
      define_method(klass.to_do_request){ |params| klass.create(params).save! }
      define_method(klass.to_create_request){ |params| klass.create(params).to_raw_tx }
    end

    # :method: do_balance
    # # Sends a do_balance call to the counterpartyd server, given the provided params

    # :method: create_balance
    # # Sends a create_balance call to the counterpartyd server, given the provided params

    # :method: do_bet
    # # Sends a do_bet call to the counterpartyd server, given the provided params

    # :method: create_bet
    # # Sends a create_bet call to the counterpartyd server, given the provided params

    # :method: do_betmatch
    # # Sends a do_betmatch call to the counterpartyd server, given the provided params

    # :method: create_betmatch
    # # Sends a create_betmatch call to the counterpartyd server, given the provided params

    # :method: do_broadcast
    # # Sends a do_broadcast call to the counterpartyd server, given the provided params

    # :method: create_broadcast
    # # Sends a create_broadcast call to the counterpartyd server, given the provided params

    # :method: do_btcpays
    # # Sends a do_btcpays call to the counterpartyd server, given the provided params

    # :method: create_btcpay
    # # Sends a create_btcpay call to the counterpartyd server, given the provided params

    # :method: do_burn
    # # Sends a do_burn call to the counterpartyd server, given the provided params

    # :method: create_burn
    # # Sends a create_burn call to the counterpartyd server, given the provided params

    # :method: do_callback
    # # Sends a do_callback call to the counterpartyd server, given the provided params

    # :method: create_callback
    # # Sends a create_callback call to the counterpartyd server, given the provided params

    # :method: do_cancel
    # # Sends a do_cancel call to the counterpartyd server, given the provided params

    # :method: create_cancel
    # # Sends a create_cancel call to the counterpartyd server, given the provided params

    # :method: do_credit
    # # Sends a do_credit call to the counterpartyd server, given the provided params

    # :method: create_credit
    # # Sends a create_credit call to the counterpartyd server, given the provided params

    # :method: do_debit
    # # Sends a do_debit call to the counterpartyd server, given the provided params

    # :method: create_debit
    # # Sends a create_debit call to the counterpartyd server, given the provided params

    # :method: do_dividend
    # # Sends a do_dividend call to the counterpartyd server, given the provided params

    # :method: create_dividend
    # # Sends a create_dividend call to the counterpartyd server, given the provided params

    # :method: do_issuance
    # # Sends a do_issuance call to the counterpartyd server, given the provided params

    # :method: create_issuance
    # # Sends a create_issuance call to the counterpartyd server, given the provided params

    # :method: do_order
    # # Sends a do_order call to the counterpartyd server, given the provided params

    # :method: create_order
    # # Sends a create_order call to the counterpartyd server, given the provided params

    # :method: do_ordermatch
    # # Sends a do_ordermatch call to the counterpartyd server, given the provided params

    # :method: create_ordermatch
    # # Sends a create_ordermatch call to the counterpartyd server, given the provided params

    # :method: do_send
    # # Sends a do_send call to the counterpartyd server, given the provided params

    # :method: create_send
    # # Sends a create_send call to the counterpartyd server, given the provided params

    # :method: do_message
    # # Sends a do_message call to the counterpartyd server, given the provided params

    # :method: create_message
    # # Sends a create_message call to the counterpartyd server, given the provided params

    # :method: do_callback
    # # Sends a do_callback call to the counterpartyd server, given the provided params

    # :method: create_callback
    # # Sends a create_callback call to the counterpartyd server, given the provided params

    # :method: do_betexpiration
    # # Sends a do_betexpiration call to the counterpartyd server, given the provided params

    # :method: create_betexpiration
    # # Sends a create_betexpiration call to the counterpartyd server, given the provided params

    # :method: do_orderexpiration
    # # Sends a do_orderexpiration call to the counterpartyd server, given the provided params

    # :method: create_orderexpiration
    # # Sends a create_orderexpiration call to the counterpartyd server, given the provided params

    # :method: do_betmatchexpiration
    # # Sends a do_betmatchexpiration call to the counterpartyd server, given the provided params

    # :method: create_betmatchexpiration
    # # Sends a create_betmatchexpiration call to the counterpartyd server, given the provided params

    # :method: do_ordermatchexpiration
    # # Sends a do_ordermatchexpiration call to the counterpartyd server, given the provided params

    # :method: create_ordermatchexpiration
    # # Sends a create_ordermatchexpiration call to the counterpartyd server, given the provided params

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
