module Counterparty

  # An object that describes a balance that is associated to a specific address.
  class Balance < CounterResource
    # (string): The address that has the balance
    attr_accessor :address

    # (string): The ID of the asset in which the balance is specified
    attr_accessor :asset

    # (integer): The balance of the specified asset at this address
    attr_accessor :quantity
  end

  # An object that describes a specific bet.
  class Bet < CounterResource
    # Bet Type: Bullish CFD 
    BULLISH_CFD = 0

    # Bet Type: Bearish CFD
    BEARISH_CFD = 1

    # Bet Type: Equal
    EQUAL = 2

    # Bet Type: Not Equal
    NOT_EQUAL = 3
    
    # (integer): The transaction index
    attr_accessor :tx_index 

    # (string): The transaction hash
    attr_accessor :tx_hash 

    # (integer): The block index (block number in the block chain)
    attr_accessor :block_index 

    # (string): The address that made the bet
    attr_accessor :source 

    # (string): The address with the feed that the bet is to be made on
    attr_accessor :feed_address 

    # (integer): 0 for Bullish CFD, 1 for Bearish CFD, 2 for Equal, 3 for Not 
    # Equal
    attr_accessor :bet_type 

    # (integer): The timestamp at which the bet should be decided/settled, in 
    # Unix time.
    attr_accessor :deadline 

    # (integer): The quantity of XCP to wager
    attr_accessor :wager_quantity 

    # (integer): The minimum quantity of XCP to be wagered by the user to bet 
    # against the bet issuer, if the other party were to accept the whole thing
    attr_accessor :counterwager_quantity 

    # (integer): The quantity of XCP wagered that is remaining to bet on
    attr_accessor :wager_remaining 

    # (float):
    attr_accessor :odds 

    # (float): Target value for Equal/NotEqual bet
    attr_accessor :target_value 

    # (integer): Leverage, as a fraction of 5040
    attr_accessor :leverage 

    # (integer): The number of blocks for which the bet should be valid
    attr_accessor :expiration 

    # (integer):
    attr_accessor :fee_multiplier 

    # (string): Set to "valid" if a valid bet. Any other setting signifies an 
    # invalid/improper bet 
    attr_accessor :validity 

    # (integer): The quantity of XCP to wager. (Only used in Create)
    attr_accessor :wager

    # (integer): The minimum quantity of XCP to be 
    # wagered against, for the bets to match. (Only used in Create)
    attr_accessor :counterwager 
  end

  # An object that describes a specific occurance of two bets being matched 
  # (either partially, or fully).
  class BetMatch < CounterResource
    # (integer): The Bitcoin transaction index of the initial bet
    attr_accessor :tx0_index 

    # (string): The Bitcoin transaction hash of the initial bet
    attr_accessor :tx0_hash 

    # (integer): The Bitcoin block index of the initial bet
    attr_accessor :tx0_block_index 

    # (integer): The number of blocks over which the initial bet was valid
    attr_accessor :tx0_expiration 

    # (string): The address that issued the initial bet
    attr_accessor :tx0_address 

    # (string): The type of the initial bet (0 for Bullish CFD, 
    # 1 for Bearish CFD, 2 for Equal, 3 for Not Equal)
    attr_accessor :tx0_bet_type 

    # (integer): The transaction index of the matching (counter) bet
    attr_accessor :tx1_index 

    # (string): The transaction hash of the matching bet
    attr_accessor :tx1_hash 

    # (integer): The block index of the matching bet
    attr_accessor :tx1_block_index 

    # (string): The address that issued the matching bet
    attr_accessor :tx1_address 

    # (integer): The number of blocks over which the matching bet was valid
    attr_accessor :tx1_expiration 

    # (string): The type of the counter bet (0 for Bullish CFD, 
    # 1 for Bearish CFD, 2 for Equal, 3 for Not Equal)
    attr_accessor :tx1_bet_type 

    # (string): The address of the feed that the bets refer to
    attr_accessor :feed_address 

    # (integer):
    attr_accessor :initial_value 

    # (integer): The timestamp at which the bet match was made, in Unix time.
    attr_accessor :deadline 

    # (float): Target value for Equal/NotEqual bet
    attr_accessor :target_value 

    # (integer): Leverage, as a fraction of 5040
    attr_accessor :leverage 

    # (integer): The quantity of XCP bet in the initial bet
    attr_accessor :forward_quantity 

    # (integer): The quantity of XCP bet in the matching bet
    attr_accessor :backward_quantity 

    # (integer):
    attr_accessor :fee_multiplier 

    # (string): Set to "valid" if a valid order match. Any other setting 
    # signifies an invalid/improper order match
    attr_accessor :validity 
  end

  # An object that describes a specific occurance of a broadcast event 
  # (i.e. creating/extending a feed)
  class Broadcast < CounterResource
    # (integer): The transaction index
    attr_accessor :tx_index 

    # (string): The transaction hash
    attr_accessor :tx_hash 

    # (integer): The block index (block number in the block chain)
    attr_accessor :block_index 

    # (string): The address that made the broadcast
    attr_accessor :source 

    # (string): The time the broadcast was made, in Unix time.
    attr_accessor :timestamp 

    # (float): The numerical value of the broadcast
    attr_accessor :value 

    # (float): How much of every bet on this feed should go to its operator; 
    # a fraction of 1, (i.e. .05 is five percent)
    attr_accessor :fee_multiplier 

    # (string): The textual component of the broadcast
    attr_accessor :text 

    # (string): Set to "valid" if a valid broadcast. Any other setting signifies 
    # an invalid/improper broadcast
    attr_accessor :validity 

    # (float): How much of every bet on this feed should go to its 
    # operator; a fraction of 1, (i.e. .05 is five percent). Used on create.
    attr_accessor :fee_fraction
  end

  # An object that matches a request to settle an Order Match for which BTC is 
  # owed.
  class BTCPay < CounterResource
    # (integer): The transaction index
    attr_accessor :tx_index 

    # (string): The transaction hash
    attr_accessor :tx_hash 

    # (integer): The block index (block number in the block chain)
    attr_accessor :block_index 

    # source (string):
    attr_accessor :source 

    # (string):
    attr_accessor :order_match_id 

    # (string): Set to "valid" if valid
    attr_accessor :validity 

    def self.api_name; 'btcpays'; end 
  end

  # An object that describes an instance of a specific burn.
  class Burn < CounterResource 
    # (integer): The transaction index
    attr_accessor :tx_index

    # (string): The transaction hash
    attr_accessor :tx_hash

    # (integer): The block index (block number in the block chain)
    attr_accessor :block_index

    # (string): The address the burn was performed from
    attr_accessor :source

    # (integer): The quantity of BTC burned
    attr_accessor :burned

    # (integer): The quantity of XPC actually earned from the burn (takes into 
    # account any bonus quantitys, 1 BTC limitation, etc)
    attr_accessor :earned

    # (string): Set to "valid" if a valid burn. Any other setting signifies an 
    # invalid/improper burn
    attr_accessor :validity

    # (string): Set to "valid" if a valid burn. Any other setting signifies an 
    # invalid/improper burn
    attr_accessor :status
    
    # (integer): The amount of BTC to burn (only used in the Create Burn) 
    attr_accessor :quantity
  end

  # An object that describes a specific asset callback (i.e. the exercising of 
  # a call option on an asset owned by the source address).
  class Callback < CounterResource
    # (integer): The transaction index
    attr_accessor :tx_index 

    # (string): The transaction hash
    attr_accessor :tx_hash 

    # block_index (integer): The block index (block number in the block chain)
    attr_accessor :block_index 

    # (string): The source address of the call back (should be the current owner 
    # of the asset)
    attr_accessor :source 

    # (integer): A floating point number greater than zero but less than or 
    # equal to 1, where 0% is for a callback of 0%
    attr_accessor :fraction 

    # of the balance of each of the asset's holders, and 1 would be for a 
    # callback of 100%). For example, 0.56 would be 56%. Each holder of the 
    # called asset will be paid the call price for the asset, times the number 
    # of units of that asset that were called back from them.
    attr_accessor :of 

    # (string): The asset being called back
    attr_accessor :asset 

    # (string): Set to "valid" if a valid send. Any other setting signifies an 
    # invalid/improper send
    attr_accessor :validity 
  end

  # An object that describes a cancellation of a (previously) open order or bet.
  class Cancel < CounterResource
    # (integer): The transaction index
    attr_accessor :tx_index 

    # (string): The transaction hash
    attr_accessor :tx_hash 

    # (integer): The block index (block number in the block chain)
    attr_accessor :block_index 

    # (string): The address with the open order or bet that was cancelled
    attr_accessor :source 

    # (string): The transaction hash of the order or bet cancelled
    attr_accessor :offer_hash 

    # (string): Set to "valid" if a valid burn. Any other setting signifies an 
    # invalid/improper burn
    attr_accessor :validity 
  end

  # An object that describes a account credit.
  class Credit < CounterResource
    # (integer): The transaction index
    attr_accessor :tx_index

    # (string): The transaction hash
    attr_accessor :tx_hash

    # (integer): The block index (block number in the block chain)
    attr_accessor :block_index

    # (string): The address debited or credited
    attr_accessor :address

    # (string): The asset debited or credited
    attr_accessor :asset

    # (integer): The quantity of the specified asset debited or credited
    attr_accessor :quantity

    attr_accessor :action

    attr_accessor :event
  end

  # An object that describes a account debit or credit.
  class Debit < CounterResource
    # (integer): The transaction index
    attr_accessor :tx_index

    # (string): The transaction hash
    attr_accessor :tx_hash

    # (integer): The block index (block number in the block chain)
    attr_accessor :block_index

    # (string): The address debited or credited
    attr_accessor :address

    # (string): The asset debited or credited
    attr_accessor :asset

    # (integer): The quantity of the specified asset debited or credited
    attr_accessor :quantity

    attr_accessor :action

    attr_accessor :event
  end

  # An object that describes an issuance of dividends on a specific user 
  # defined asset.
  class Dividend < CounterResource
    # (integer): The transaction index
    attr_accessor :tx_index 

    # (string): The transaction hash
    attr_accessor :tx_hash 

    # (integer): The block index (block number in the block chain)
    attr_accessor :block_index 

    # (string): The address that issued the dividend
    attr_accessor :source 

    # (string): The asset that the dividends are being rewarded on
    attr_accessor :asset 

    # (integer): The quantity of XCP rewarded per whole unit of the asset
    attr_accessor :quantity_per_unit 

    # (string): Set to "valid" if a valid burn. Any other setting signifies an 
    # invalid/improper burn
    attr_accessor :validity 

    # (string, required): The asset that the dividends are paid in.
    attr_accessor :dividend_asset
  end

  # An object that describes a specific occurance of a user defined asset being 
  # issued, or re-issued
  class Issuance < CounterResource
    # (integer): The transaction index
    attr_accessor :tx_index 

    # (string): The transaction hash
    attr_accessor :tx_hash 

    # (integer): The block index (block number in the block chain)
    attr_accessor :block_index 

    # (string): The asset being issued, or re-issued
    attr_accessor :asset 

    # (integer): The quantity of the specified asset being issued
    attr_accessor :quantity 

    # (boolean): Whether or not the asset is divisible (must agree with previous 
    # issuances of the asset, if there are any)
    attr_accessor :divisible 

    # issuer (string):
    attr_accessor :issuer 

    # (boolean): Whether or not this objects marks the transfer of ownership 
    # rights for the specified quantity of this asset
    attr_accessor :transfer 

    # (string): Set to "valid" if a valid issuance. Any other setting signifies 
    # an invalid/improper issuance
    attr_accessor :validity 

    # (string): This is used when creating an issuance, and indicates the source
    # address of the asset
    attr_accessor :source
    
    # (string): This is used when creating an issuance, and indicates 
    # the destination address of the asset
    attr_accessor :description

    # (string): This is used when creating an issuance transfer, and indicates 
    # the destination address of the asset
    attr_accessor :transfer_destination
  end

  # An object that describes a specific order.
  class Order < CounterResource
    # (integer): The transaction index
    attr_accessor :tx_index 

    # (string): The transaction hash
    attr_accessor :tx_hash 

    # (integer): The block index (block number in the block chain)
    attr_accessor :block_index 

    # (string): The address that made the order
    attr_accessor :source 

    # (string): The asset being offered
    attr_accessor :give_asset 

    # (integer): The quantity of the specified asset being offered
    attr_accessor :give_quantity 

    # (integer): The quantity of the specified give asset remaining for the order
    attr_accessor :give_remaining 

    # (string): The asset desired in exchange
    attr_accessor :get_asset 

    # (integer): The quantity of the specified asset desired in exchange
    attr_accessor :get_quantity 

    # (integer): The quantity of the specified get asset remaining for the order
    attr_accessor :get_remaining 

    # (float): The given exchange rate (as an exchange ratio desired from the 
    # asset offered to the asset desired)
    attr_accessor :price 

    # (integer): The number of blocks over which the order should be valid
    attr_accessor :expiration 

    # (integer): The miners' fee provided; in BTC; required only if selling BTC 
    # (should not be lower than is required for acceptance in a block)
    attr_accessor :fee_provided 

    # (integer): The miners' fee required to be paid by orders for them to match 
    # this one; in BTC; required only if buying BTC (may be zero, though)
    attr_accessor :fee_required 
  end

  # An object that describes a specific occurance of two orders being matched 
  # (either partially, or fully)
  class OrderMatch < CounterResource
    # (integer): The Bitcoin transaction index of the first (earlier) order
    attr_accessor :tx0_index 

    # (string): The Bitcoin transaction hash of the first order
    attr_accessor :tx0_hash 

    # (integer): The Bitcoin block index of the first order
    attr_accessor :tx0_block_index 

    # (integer): The number of blocks over which the first order was valid
    attr_accessor :tx0_expiration 

    # (string): The address that issued the first (earlier) order
    attr_accessor :tx0_address 

    # (integer): The transaction index of the second (matching) order
    attr_accessor :tx1_index 

    # (string): The transaction hash of the second order
    attr_accessor :tx1_hash 

    # (integer): The block index of the second order
    attr_accessor :tx1_block_index 

    # (string): The address that issued the second order
    attr_accessor :tx1_address 

    # (integer): The number of blocks over which the second order was valid
    attr_accessor :tx1_expiration 

    # (string): The asset exchanged FROM the first order to the second order
    attr_accessor :forward_asset 

    # (integer): The quantity of the specified forward asset
    attr_accessor :forward_quantity 

    # (string): The asset exchanged FROM the second order to the first order
    attr_accessor :backward_asset 

    # (integer): The quantity of the specified backward asset
    attr_accessor :backward_quantity 

    # (string): Set to "valid" if a valid order match. Any other setting 
    # signifies an invalid/improper order match
    attr_accessor :validity 
  end

  # An object that describes a specific send (e.g. "simple send", of XCP, or a 
  # user defined asset).
  class Send < CounterResource
    # (integer): The transaction index
    attr_accessor :tx_index

    # (string): The transaction hash
    attr_accessor :tx_hash

    # (integer): The block index (block number in the block chain)
    attr_accessor :block_index

    # (string): The source address of the send
    attr_accessor :source

    # (string): The destination address of the send
    attr_accessor :destination

    # (string): The asset being sent
    attr_accessor :asset

    # (integer): The quantity of the specified asset sent
    attr_accessor :quantity

    # (string): Set to "valid" if a valid send. Any other setting signifies an 
    # invalid/improper send
    attr_accessor :validity
  end

  # An object that describes a specific event in the counterpartyd message feed 
  # (which can be used by 3rd party applications to track state changes to the 
  # counterpartyd database on a block-by-block basis).
  class Message < CounterResource
    # (integer): The message index (i.e. transaction index)
    attr_accessor :message_index 

    # (integer): The block index (block number in the block chain) this event 
    # occurred on
    attr_accessor :block_index 

    # (string): A string denoting the entity that the message relates to, e.g. 
    # "credits", "burns", "debits". The category matches the relevant table name 
    # in counterpartyd (see blocks.py for more info).
    attr_accessor :category 

    # (string): The operation done to the table noted in category. This is 
    # either "insert", or "update".
    attr_accessor :command 

    # (string): A JSON-encoded object containing the message data. The 
    # properties in this object match the columns in the table referred to by category.
    attr_accessor :bindings 
  end

  # An object that describes a specific asset callback (i.e. the exercising of 
  # a call option on an asset owned by the source address).
  class Callback < CounterResource
    # (integer): The transaction index
    attr_accessor :tx_index 

    # (string): The transaction hash
    attr_accessor :tx_hash 

    # (integer): The block index (block number in the block chain)
    attr_accessor :block_index 

    # (string): The source address of the call back (should be the current owner 
    # of the asset)
    attr_accessor :source 

    # (integer): A floating point number greater than zero but less than 
    # or equal to 1, where 0% is for a callback of 0% of the balance of each of 
    # the asset's holders, and 1 would be for a callback of 100%). For example,
    # 0.56 would be 56%. Each holder of the called asset will be paid the call 
    # price for the asset, times the number of units of that asset that were 
    # called back from them.
    attr_accessor :fraction 

    # asset (string): The asset being called back
    attr_accessor :asset 

    # (string): Set to "valid" if a valid send. Any other setting signifies an 
    # invalid/improper send
    attr_accessor :validity 
  end

  # An object that describes the expiration of a bet created by the source 
  # address.
  class BetExpiration < CounterResource
    # (integer): The transaction index of the bet expiring
    attr_accessor :bet_index 

    # bet_hash (string): The transaction hash of the bet expiriing
    attr_accessor :bet_hash 

    # (integer): The block index (block number in the block chain) when this 
    # expiration occurred
    attr_accessor :block_index 

    # (string): The source address that created the bet
    attr_accessor :source 
  end

  # An object that describes the expiration of an order created by the source 
  # address.
  class OrderExpiration < CounterResource
    # (integer): The transaction index of the order expiring
    attr_accessor :order_index 

    # (string): The transaction hash of the order expiriing
    attr_accessor :order_hash 

    # (integer): The block index (block number in the block chain) when this 
    # expiration occurred
    attr_accessor :block_index 

    # (string): The source address that created the order
    attr_accessor :source 
  end

  # An object that describes the expiration of a bet match.
  class BetMatchExpiration < CounterResource
    # (integer): The transaction index of the bet match ID (e.g. the 
    # concatenation of the tx0 and tx1 hashes)
    attr_accessor :bet_match_id 

    # (string): The tx0 (first) address for the bet match
    attr_accessor :tx0_address 

    # (string): The tx1 (second) address for the bet match
    attr_accessor :tx1_address 

    # (integer): The block index (block number in the block chain) when this 
    # expiration occurred
    attr_accessor :block_index 
  end

  # An object that describes the expiration of an order match.
  class OrderMatchExpiration < CounterResource
    # (integer): The transaction index of the order match ID (e.g. the 
    # concatenation of the tx0 and tx1 hashes)
    attr_accessor :order_match_id 

    # (string): The tx0 (first) address for the order match
    attr_accessor :tx0_address 

    # (string): The tx1 (second) address for the order match
    attr_accessor :tx1_address 

    # (integer): The block index (block number in the block chain) when this 
    # expiration occurred
    attr_accessor :block_index 
  end
  
  # An object that publishes a compiled serpent contract onto the Counterparty
  # network
  class Publish < CounterResource
    # (string) the source address
    attr_accessor :source

    # (integer) the price of gas
    attr_accessor :gasprice

    # (integer) the maximum quantity of {} to be used to pay for the execution (satoshis)
    attr_accessor :startgas

    # (integer) quantity of {} to be transfered to the contract (satoshis)
    attr_accessor :endowment

    # (string) the hex‐encoded contract (returned by 'serpent compile')
    attr_accessor :code_hex
  end

  # An object that executes contract code in the blockchain
  class Execute < CounterResource
    # (string) the source address
    attr_accessor :source

    # (integer) the price of gas
    attr_accessor :gasprice

    # (integer) the maximum quantity of {} to be used to pay for the execution (satoshis
    attr_accessor :startgas

    # (integer) the contract ID of the contract to be executed
    attr_accessor :contract_id

    # (integer) quantity to be transfered to the contract (satoshis)
    attr_accessor :value
    
    # (string) data to be provided to the contract (returned by serpent encode_datalist)
    attr_accessor :payload_hex
  end
end
