module Counterparty

  # A base class for the purpose of extending by api result hashes
  class ResultClass
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

    def self.to_get_request
      'get_%ss' % to_s.split('::').last.gsub(/[^\A]([A-Z])/, '_\\1').downcase
    end
  end

  # This is returned via get_balance
  class Balance < ResultClass
    # address (string): The address that has the balance
    attr_accessor :address

    # asset (string): The ID of the :ref:`asset <assets>` in which the balance is specified
    attr_accessor :asset

    # quantity (integer): The :ref:`balance <quantitys>` of the specified asset at this address
    attr_accessor :quantity
  end

  class Bet < ResultClass
  end

  class BetMatch < ResultClass
  end

  class Broadcast < ResultClass
  end

  class BTCPay < ResultClass
    def self.to_get_request; 'get_btcpays'; end 
  end

  # This is returned via get_burns, and represents a Burn transaction
  class Burn < ResultClass 
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

  class Callback < ResultClass
  end

  class Cancel < ResultClass
  end

  class Credit < ResultClass
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

  class Debit < ResultClass
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

  class Dividend < ResultClass
  end

  class Issuance < ResultClass
  end

  class Order < ResultClass
  end

  class OrderMatch < ResultClass
  end

  class Send < ResultClass
  end

  class Message < ResultClass
  end

  class Callback < ResultClass
  end

  class BetExpiration < ResultClass
  end

  class OrderExpiration < ResultClass
  end

  class BetMatchExpiration < ResultClass
  end

  class OrderMatchExpiration < ResultClass
  end

  class Rps < ResultClass
  end

  class RpsExpiration < ResultClass
  end

  class RpsMatches < ResultClass
  end

  class RpsMatchExpiration < ResultClass
  end

  class RpsResolve < ResultClass
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
