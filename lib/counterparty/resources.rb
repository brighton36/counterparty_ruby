module Counterparty

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
    #tx_index (integer): The transaction index
    #tx_hash (string): The transaction hash
    #block_index (integer): The block index (block number in the block chain)
    #source (string): The address that made the bet
    #feed_address (string): The address with the feed that the bet is to be made on
    #bet_type (integer): 0 for Bullish CFD, 1 for Bearish CFD, 2 for Equal, 3 for Not Equal
    #deadline (integer): The timestamp at which the bet should be decided/settled, in Unix time.
    #wager_quantity (integer): The :ref:`quantity <quantitys>` of XCP to wager
    #counterwager_quantity (integer): The minimum :ref:`quantity <quantitys>` of XCP to be wagered by the user to bet against the bet issuer, if the other party were to accept the whole thing
    #wager_remaining (integer): The quantity of XCP wagered that is remaining to bet on
    #odds (float):
    #target_value (float): Target value for Equal/NotEqual bet
    #leverage (integer): Leverage, as a fraction of 5040
    #expiration (integer): The number of blocks for which the bet should be valid
    #fee_multiplier (integer):
    #validity (string): Set to "valid" if a valid bet. Any other setting signifies an invalid/improper bet 
  end

  class BetMatch < CounterResource
    #tx0_index (integer): The Bitcoin transaction index of the initial bet
    #tx0_hash (string): The Bitcoin transaction hash of the initial bet
    #tx0_block_index (integer): The Bitcoin block index of the initial bet
    #tx0_expiration (integer): The number of blocks over which the initial bet was valid
    #tx0_address (string): The address that issued the initial bet
    #tx0_bet_type (string): The type of the initial bet (0 for Bullish CFD, 1 for Bearish CFD, 2 for Equal, 3 for Not Equal)
    #tx1_index (integer): The transaction index of the matching (counter) bet
    #tx1_hash (string): The transaction hash of the matching bet
    #tx1_block_index (integer): The block index of the matching bet
    #tx1_address (string): The address that issued the matching bet
    #tx1_expiration (integer): The number of blocks over which the matching bet was valid
    #tx1_bet_type (string): The type of the counter bet (0 for Bullish CFD, 1 for Bearish CFD, 2 for Equal, 3 for Not Equal)
    #feed_address (string): The address of the feed that the bets refer to
    #initial_value (integer):
    #deadline (integer): The timestamp at which the bet match was made, in Unix time.
    #target_value (float): Target value for Equal/NotEqual bet
    #leverage (integer): Leverage, as a fraction of 5040
    #forward_quantity (integer): The :ref:`quantity <quantitys>` of XCP bet in the initial bet
    #backward_quantity (integer): The :ref:`quantity <quantitys>` of XCP bet in the matching bet
    #fee_multiplier (integer):
    #validity (string): Set to "valid" if a valid order match. Any other setting signifies an invalid/improper order match
  end

  class Broadcast < CounterResource
    #tx_index (integer): The transaction index
    #tx_hash (string): The transaction hash
    #block_index (integer): The block index (block number in the block chain)
    #source (string): The address that made the broadcast
    #timestamp (string): The time the broadcast was made, in Unix time.
    #value (float): The numerical value of the broadcast
    #fee_multiplier (float): How much of every bet on this feed should go to its operator; a fraction of 1, (i.e. .05 is five percent)
    #text (string): The textual component of the broadcast
    #validity (string): Set to "valid" if a valid broadcast. Any other setting signifies an invalid/improper broadcast
  end

  class BTCPay < CounterResource
    #tx_index (integer): The transaction index
    #tx_hash (string): The transaction hash
    #block_index (integer): The block index (block number in the block chain)
    #source (string):
    #order_match_id (string):
    #validity (string): Set to "valid" if valid

    def self.api_name; 'btcpays'; end 
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
    #tx_index (integer): The transaction index
    #tx_hash (string): The transaction hash
    #block_index (integer): The block index (block number in the block chain)
    #source (string): The source address of the call back (should be the current owner of the asset)
    #fraction (integer): A floating point number greater than zero but less than or equal to 1, where 0% is for a callback of 0%
    #of the balance of each of the asset's holders, and 1 would be for a callback of 100%). For example, 0.56 would be 56%. Each holder of the called asset will be paid the call price for the asset, times the number of units of that asset that were called back from them.
    #asset (string): The :ref:`asset <assets>` being called back
    #validity (string): Set to "valid" if a valid send. Any other setting signifies an invalid/improper send
  end

  class Cancel < CounterResource
    #tx_index (integer): The transaction index
    #tx_hash (string): The transaction hash
    #block_index (integer): The block index (block number in the block chain)
    #source (string): The address with the open order or bet that was cancelled
    #offer_hash (string): The transaction hash of the order or bet cancelled
    #validity (string): Set to "valid" if a valid burn. Any other setting signifies an invalid/improper burn
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
    #tx_index (integer): The transaction index
    #tx_hash (string): The transaction hash
    #block_index (integer): The block index (block number in the block chain)
    #source (string): The address that issued the dividend
    #asset (string): The :ref:`asset <assets>` that the dividends are being rewarded on
    #quantity_per_unit (integer): The :ref:`quantity <quantitys>` of XCP rewarded per whole unit of the asset
    #validity (string): Set to "valid" if a valid burn. Any other setting signifies an invalid/improper burn
  end

  class Issuance < CounterResource
    #tx_index (integer): The transaction index
    #tx_hash (string): The transaction hash
    #block_index (integer): The block index (block number in the block chain)
    #asset (string): The :ref:`asset <assets>` being issued, or re-issued
    #quantity (integer): The :ref:`quantity <quantitys>` of the specified asset being issued
    #divisible (boolean): Whether or not the asset is divisible (must agree with previous issuances of the asset, if there are any)
    #issuer (string):
    #transfer (boolean): Whether or not this objects marks the transfer of ownership rights for the specified quantity of this asset
    #validity (string): Set to "valid" if a valid issuance. Any other setting signifies an invalid/improper issuance
  end

  class Order < CounterResource
    #tx_index (integer): The transaction index
    #tx_hash (string): The transaction hash
    #block_index (integer): The block index (block number in the block chain)
    #source (string): The address that made the order
    #give_asset (string): The :ref:`asset <assets>` being offered
    #give_quantity (integer): The :ref:`quantity <quantitys>` of the specified asset being offered
    #give_remaining (integer): The :ref:`quantity <quantitys>` of the specified give asset remaining for the order
    #get_asset (string): The :ref:`asset <assets>` desired in exchange
    #get_quantity (integer): The :ref:`quantity <quantitys>` of the specified asset desired in exchange
    #get_remaining (integer): The :ref:`quantity <quantitys>` of the specified get asset remaining for the order
    #price (float): The given exchange rate (as an exchange ratio desired from the asset offered to the asset desired)
    #expiration (integer): The number of blocks over which the order should be valid
    #fee_provided (integer): The miners' fee provided; in BTC; required only if selling BTC (should not be lower than is required for acceptance in a block)
    #fee_required (integer): The miners' fee required to be paid by orders for them to match this one; in BTC; required only if buying BTC (may be zero, though)
  end

  class OrderMatch < CounterResource
    #tx0_index (integer): The Bitcoin transaction index of the first (earlier) order
    #tx0_hash (string): The Bitcoin transaction hash of the first order
    #tx0_block_index (integer): The Bitcoin block index of the first order
    #tx0_expiration (integer): The number of blocks over which the first order was valid
    #tx0_address (string): The address that issued the first (earlier) order
    #tx1_index (integer): The transaction index of the second (matching) order
    #tx1_hash (string): The transaction hash of the second order
    #tx1_block_index (integer): The block index of the second order
    #tx1_address (string): The address that issued the second order
    #tx1_expiration (integer): The number of blocks over which the second order was valid
    #forward_asset (string): The :ref:`asset <assets>` exchanged FROM the first order to the second order
    #forward_quantity (integer): The :ref:`quantity <quantitys>` of the specified forward asset
    #backward_asset (string): The :ref:`asset <assets>` exchanged FROM the second order to the first order
    #backward_quantity (integer): The :ref:`quantity <quantitys>` of the specified backward asset
    #validity (string): Set to "valid" if a valid order match. Any other setting signifies an invalid/improper order match
  end

  class Send < CounterResource
    # tx_index (integer): The transaction index
    attr_accessor :tx_index

    # tx_hash (string): The transaction hash
    attr_accessor :tx_hash

    # block_index (integer): The block index (block number in the block chain)
    attr_accessor :block_index

    # source (string): The source address of the send
    attr_accessor :source

    # destination (string): The destination address of the send
    attr_accessor :destination

    # asset (string): The :ref:`asset <assets>` being sent
    attr_accessor :asset

    # quantity (integer): The :ref:`quantity <quantitys>` of the specified asset sent
    attr_accessor :quantity

    # validity (string): Set to "valid" if a valid send. Any other setting signifies an invalid/improper send
    attr_accessor :validity


  end

  class Message < CounterResource
    #message_index (integer): The message index (i.e. transaction index)
    #block_index (integer): The block index (block number in the block chain) this event occurred on
    #category (string): A string denoting the entity that the message relates to, e.g. "credits", "burns", "debits". The category matches the relevant table name in counterpartyd (see blocks.py for more info).
    #command (string): The operation done to the table noted in category. This is either "insert", or "update".
    #bindings (string): A JSON-encoded object containing the message data. The properties in this object match the columns in the table referred to by category.
  end

  class Callback < CounterResource
    #tx_index (integer): The transaction index

    #tx_hash (string): The transaction hash

    #block_index (integer): The block index (block number in the block chain)

    #source (string): The source address of the call back (should be the current owner of the asset)

    #fraction (integer): A floating point number greater than zero but less than or equal to 1, where 0% is for a callback of 0%
    #of the balance of each of the asset's holders, and 1 would be for a callback of 100%). For example, 0.56 would be 56%. Each holder of the called asset will be paid the call price for the asset, times the number of units of that asset that were called back from them.

    #asset (string): The :ref:`asset <assets>` being called back

    #validity (string): Set to "valid" if a valid send. Any other setting signifies an invalid/improper send
  end

  class BetExpiration < CounterResource
    #bet_index (integer): The transaction index of the bet expiring
    #bet_hash (string): The transaction hash of the bet expiriing
    #block_index (integer): The block index (block number in the block chain) when this expiration occurred
    #source (string): The source address that created the bet
  end

  class OrderExpiration < CounterResource
    #order_index (integer): The transaction index of the order expiring
    #order_hash (string): The transaction hash of the order expiriing
    #block_index (integer): The block index (block number in the block chain) when this expiration occurred
    #source (string): The source address that created the order
  end

  class BetMatchExpiration < CounterResource
    #bet_match_id (integer): The transaction index of the bet match ID (e.g. the concatenation of the tx0 and tx1 hashes)
    #tx0_address (string): The tx0 (first) address for the bet match
    #tx1_address (string): The tx1 (second) address for the bet match
    #block_index (integer): The block index (block number in the block chain) when this expiration occurred
  end

  class OrderMatchExpiration < CounterResource
    #order_match_id (integer): The transaction index of the order match ID (e.g. the concatenation of the tx0 and tx1 hashes)
    #tx0_address (string): The tx0 (first) address for the order match
    #tx1_address (string): The tx1 (second) address for the order match
    #block_index (integer): The block index (block number in the block chain) when this expiration occurred
  end

end
