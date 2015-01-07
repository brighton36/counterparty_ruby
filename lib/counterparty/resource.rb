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
    #
    # NOTE: This method communicates your private key to the counterpartyd
    # server, which might not be what you want!
    def to_signed_tx(private_key)
      sign_tx to_raw_tx, private_key
    end

    # Commit this object to the blockchain. If a private key is passed, the 
    # transaction is signed using this key via a create_ call and a subsequent
    # sign_tx call. 
    # NOTE: This method communicates your private key to the counterpartyd
    # server, which might not be what you want!
    def save!(private_key = nil)
      (private_key) ? 
        connection.broadcast_tx( to_signed_tx(private_key) ) :
        connection.request(self.class.to_do_request, to_params)
    end

    private

    # Currently this is communicating the request to the backend. This method
    # is a stub for when we decide in the future to Use the bitcoin-client gem
    # to perform signatures
    def sign_tx(raw_tx, pkey_wif)
      key = ::Bitcoin.open_key pkey_wif
      raw_tx_hash = RawTx.new(raw_tx).to_hash

      prev_hash = raw_tx_hash['vin'][0]['txid']
      prior_tx_json = open("http://test.webbtc.com/tx/#{prev_hash}.json").read
      puts prior_tx_json.inspect
      prev_tx = Bitcoin::P::Tx.from_json(prior_tx_json.to_s)

      
      puts "HERE" 
      signed_tx = Bitcoin::Protocol::Tx.new
      signed_tx.ver = raw_tx_hash['ver']
      signed_tx.lock = raw_tx_hash['lock_time']
      
      tx_in= TxInBuilder.new
      tx_in.prev_out prev_tx
      tx_in.prev_out_index 0
      tx_in.signature_key key

      signed_tx.add_in tx_in.tx

        # Here's how we put them in the raw
        # @block.tx << tx


      # We need to compare against
      # Primarily: http://www.righto.com/2014/02/bitcoins-hard-way-using-raw-bitcoin.html
      # With Some of this: https://bitcoin.org/en/developer-reference#signrawtransaction
=begin
def sign(tx, i, priv, hashcode=SIGHASH_ALL):                                    
    i = int(i)                                                                  
    if not re.match('^[0-9a-fA-F]*$', tx):                                      
        return binascii.unhexlify(sign(binascii.hexlify(tx), i, priv))          
    if len(priv) <= 33:                                                         
        priv = binascii.hexlify(priv)                                           
    pub = privkey_to_pubkey(priv)                                               
    address = pubkey_to_address(pub)                                            
    signing_tx = signature_form(tx, i, mk_pubkey_script(address), hashcode)     
    sig = ecdsa_tx_sign(signing_tx, priv, hashcode)                             
    txobj = deserialize(tx)                                                     
    txobj["ins"][i]["script"] = serialize_script([sig, pub])                    
    return serialize(txobj)                                                     
=end

      
      scriptSig = Bitcoin.sign_data(key, 
        raw_tx_hash["in"][0]["scriptSig"] ).unpack('h*').first
      # TODO: We may have to iterate over each input
      raw_tx_hash["in"][0]["scriptSig"] = scriptSig

      ret = Bitcoin::Protocol::Tx.from_hash(raw_tx_hash).to_payload.unpack('h*').first

      ret
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

      # Returns the method name of a do_* request for this resource
      def to_do_request
        'do_%s' % api_name
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

