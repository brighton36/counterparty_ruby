module Counterparty

  # A base class for the purpose of extending by api result hashes
  class CounterResource
    attr_accessor :result_attributes

    def initialize(attrs={})
      @result_attributes = attrs.keys.sort.collect(&:to_sym)
      attrs.each{|k,v| instance_variable_set '@%s' % k, v}
    end

    def ==(b)
      ( b.respond_to?(:result_attributes) &&
        result_attributes == b.result_attributes && 
        @result_attributes.all?{ |k| send(k) == b.send(k) } )
    end

    class << self
      attr_writer :connection

      def connection
        @connection || Counterparty.connection
      end

      def to_get_request
        'get_%ss' % to_s.split('::').last.gsub(/[^\A]([A-Z])/, '_\\1').downcase
      end

      def find(params)
        connection.request(to_get_request, params).collect{|r| new r}
      end
    end
  end

  # This is returned via get_balance
  class Balance < CounterResource
    # address (string): The address that has the balance
    attr_accessor :address

    # asset (string): The ID of the :ref:`asset <assets>` in which the balance is specified
    attr_accessor :asset

    # quantity (integer): The :ref:`balance <quantitys>` of the specified asset at this address
    attr_accessor :quantity
  end

  class Bet < CounterResource
  end

  class BetMatch < CounterResource
  end

  class Broadcast < CounterResource
  end

  class BTCPay < CounterResource
    def self.to_get_request; 'get_btcpays'; end 
  end

  # This is returned via get_burns, and represents a Burn transaction
  class Burn < CounterResource 
    # tx_index (integer): The transaction index
    attr_accessor :tx_index

    # tx_hash (string): The transaction hash
    attr_accessor :tx_hash

    # block_index (integer): The block index (block number in the block chain)
    attr_accessor :block_index

    # source (string): The address the burn was performed from
    attr_accessor :source

    # burned (integer): The :ref:`quantity <quantitys>` of BTC burned
    attr_accessor :burned

    # earned (integer): The :ref:`quantity <quantitys>` of XPC actually earned from the burn (takes into account any bonus quantitys, 1 BTC limitation, etc)
    attr_accessor :earned

    # validity (string): Set to "valid" if a valid burn. Any other setting signifies an invalid/improper burn
    attr_accessor :validity

    # status (string): Set to "valid" if a valid burn. Any other setting signifies an invalid/improper burn
    attr_accessor :status
  end

  class Callback < CounterResource
  end

  class Cancel < CounterResource
  end

  class Credit < CounterResource
    # tx_index (integer): The transaction index
    attr_accessor :tx_index

    # tx_hash (string): The transaction hash
    attr_accessor :tx_hash

    # block_index (integer): The block index (block number in the block chain)
    attr_accessor :block_index

    # address (string): The address debited or credited
    attr_accessor :address

    # asset (string): The :ref:`asset <assets>` debited or credited
    attr_accessor :asset

    # quantity (integer): The :ref:`quantity <quantitys>` of the specified asset debited or credited
    attr_accessor :quantity

    attr_accessor :action

    attr_accessor :event
  end

  class Debit < CounterResource
    # tx_index (integer): The transaction index
    attr_accessor :tx_index

    # tx_hash (string): The transaction hash
    attr_accessor :tx_hash

    # block_index (integer): The block index (block number in the block chain)
    attr_accessor :block_index

    # address (string): The address debited or credited
    attr_accessor :address

    # asset (string): The :ref:`asset <assets>` debited or credited
    attr_accessor :asset

    # quantity (integer): The :ref:`quantity <quantitys>` of the specified asset debited or credited
    attr_accessor :quantity

    attr_accessor :action

    attr_accessor :event
  end

  class Dividend < CounterResource
  end

  class Issuance < CounterResource
  end

  class Order < CounterResource
  end

  class OrderMatch < CounterResource
  end

  class Send < CounterResource
  end

  class Message < CounterResource
  end

  class Callback < CounterResource
  end

  class BetExpiration < CounterResource
  end

  class OrderExpiration < CounterResource
  end

  class BetMatchExpiration < CounterResource
  end

  class OrderMatchExpiration < CounterResource
  end

  class Rps < CounterResource
  end

  class RpsExpiration < CounterResource
  end

  class RpsMatches < CounterResource
  end

  class RpsMatchExpiration < CounterResource
  end

  class RpsResolve < CounterResource
    def self.to_get_request; 'rpsresolves'; end 
  end

  module ReadRequests
    def self.included(base)
      # Go ahead and setup the above classes, and throw them into the request
      # channels:
      [Balance, Bet, BetMatch, BetExpiration, BetMatchExpiration, Broadcast, 
       BTCPay, Burn, Callback, Cancel, Credit, Debit, Dividend, Issuance, Order, 
       OrderExpiration, OrderMatch, OrderMatchExpiration, Rps, RpsExpiration, 
       RpsMatches, RpsMatchExpiration, RpsResolve, Send].each do |klass|
        base.read_request klass
      end
    end
  end
end
