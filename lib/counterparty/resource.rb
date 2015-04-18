module Counterparty
  # A base class for the purpose of extending by api result hashes
  class CounterResource
    # This is mostly used by the eq operation and indicates the 
    # attributes that this resource has
    attr_accessor :result_attributes # :nodoc:
    
    # encoding (string): The encoding method to use
    attr_accessor :encoding

    # pubkey (string): The pubkey hex string. Required if multisig transaction 
    # encoding is specified for a key external to counterpartyd's local wallet.
    attr_accessor :pubkey

    # allow_unconfirmed_inputs (boolean): Set to true to allow this transaction 
    # to utilize unconfirmed UTXOs as inputs.
    attr_accessor :allow_unconfirmed_inputs

    # fee (integer): If you'd like to specify a custom miners' fee, specify it 
    # here (in satoshi). Leave as default for counterpartyd to automatically 
    # choose.
    attr_accessor :fee

    # fee_per_kb (integer): The fee per kilobyte of transaction data constant 
    # that counterpartyd uses when deciding on the dynamic fee to use 
    # (in satoshi). Leave as default unless you know what you're doing.
    attr_accessor :fee_per_kb

    def initialize(attrs={})
      @result_attributes = attrs.keys.sort.collect(&:to_sym)
      attrs.each{|k,v| instance_variable_set '@%s' % k, v}
    end

    # Just a simple compare. No need to get crazy
    def ==(b) # :nodoc:
      ( b.respond_to?(:result_attributes) &&
        result_attributes == b.result_attributes && 
        @result_attributes.all?{ |k| send(k) == b.send(k) } )
    end

    # This method returns the unsigned raw create transaction string. hex 
    # encoded (i.e. the same format that bitcoind returns with its raw 
    # transaction API calls).
    def to_raw_tx
      connection.request self.class.to_create_request, to_params
    end

    # Given the provided private key, this method returns a signed transaction
    # suitable for broadcasting on the network. 
    def to_signed_tx(private_key)
      sign_tx to_raw_tx, private_key
    end

    # Commit this object to the blockchain. If a private key is passed, the 
    # transaction is signed using this key via a create_ call and a subsequent
    # sign_tx call. 
    def save!(private_key)
      bitcoin.sendrawtransaction to_signed_tx(private_key)
    end

    private

    # Currently this is communicating the request to the backend. This method
    # is a stub for when we decide in the future to Use the bitcoin-client gem
    # to perform signatures
    def sign_tx(raw_tx, pkey_wif)
      # Seems like this is your quintessential reference: 
      # http://www.righto.com/2014/02/bitcoins-hard-way-using-raw-bitcoin.html

      # I think this is the right way to do it...
      Bitcoin.network = (@bitcoin.is_testing?) ? :testnet3 : :bitcoin

      # This parses the binary-encoded raw transaction:
      tx = Bitcoin::P::Tx.new [raw_tx].pack('H*')

      # This is the input transaction, which we'll need for signining:
      prev_hash = tx.in[0].prev_out.reverse_hth

      # let's parse the keys:
      key = Bitcoin::Key.from_base58 pkey_wif

      pubkey = [key.pub].pack('H*')

      # And parse the input transaction:
      prev_tx = Bitcoin::P::Tx.from_hash @bitcoin.gettransaction(prev_hash)

      # And, now we're ready to sign: 
      subscript = tx.signature_hash_for_input 0, prev_tx
      sig = Bitcoin.sign_data Bitcoin.open_key(key.priv), subscript
      tx.in[0].script_sig = Bitcoin::Script.to_signature_pubkey_script sig, pubkey 

      tx.to_payload.unpack('H*')[0]
    end

    def bitcoin
      self.class.bitcoin
    end

    def connection
      self.class.connection
    end

    # This serializes self into a hash suitable for transmission via json
    def to_params
      Hash[* @result_attributes.collect{|k| 
        v = self.send(k)
        (v) ? [k,self.send(k)] : nil
      }.compact.flatten]
    end

    class << self
      # The base connection object for this class
      attr_writer :connection

      # Returns the counterparty-api version of this objects class name
      def api_name
        to_s.split('::').last.gsub(/[^\A]([A-Z])/, '_\\1').downcase
      end

      # Returns the currently assigned connection object, or if one hasn't
      # been set, the default specified in the Counterparty module
      def connection
        @connection || Counterparty.connection
      end

      # Returns the currently assigned connection object, or if one hasn't
      # been set, the default specified in the Counterparty module
      def bitcoin
        @bitcoin || Counterparty.bitcoin
      end

      # Returns the method name of a create_* request for this resource
      def to_create_request
        'create_%s' % api_name
      end

      # Returns the method name of a get_* request for this resource
      def to_get_request
        'get_%ss' % api_name
      end

      # Queries the counterpartyd connection to find matching instances of this
      # resource, given the filters provided in the params
      def find(params)
        connection.request(to_get_request, params).collect{|r| new r}
      end
    end
  end
end

