counterparty_ruby [![Gem Version](https://badge.fury.io/rb/counterparty_ruby.svg)](http://badge.fury.io/rb/counterparty_ruby)
=================
A ruby gem for communicating with a Counterparty (Bitcoin / XCP) API server.

What's up party people! [Chris DeRose](https://www.chrisderose.com) here, 
community director of the [Counterparty Foundation](http://counterpartyfoundation.org/), 
and today we're going to discuss.... Ruby! Or more specifically, how to start using
counterparty in your ruby and/or ruby on rails app.

This gem is designed to abstract communications with the counterpartyd api 
server in an ActiveRecord-esque object model. But note that we also support 
calling the api methods directly via the documented api calls in the offical docs. 

Below you'll see some examples to get you started, but feel free to peruse the
specs for yet more examples. These examples all assume that you're running a 
working counterpartyd on the same system that the code is running on, but it's 
easy to specify another server connection if you'd like. (Just set the 
Counterparty.connection to a connection object that references the correct API
server).

We hope you find this useful everyone, let us know if there are any issues, and
keep us updated on the apps you're building! We're working to make this 
counterparty spool-up process as simple as possible, so bear with us while we're
setting everything up. 

![Party On Wayne](http://data.whicdn.com/images/24796384/tumblr_m0ng6rBeWT1qhd0xso1_500_large.jpg)

## Changelog
*Version 1.1.0*
  * Minor Updates to support changes in counterpartyd 1.1
  * Removed support for relaying transactions through counterparty
  * Implemented bitcoin-ruby based transaction signing
  * Added a blockr.io library for relaying signed transactions
  * save() syntax now requires that a private key be provided to persist transactions
  * Default test and production counterparty servers were changed to the vennd.io public servers

*Version 0.9*
  * First release! 

## Examples
Documentation on the objects is available via:
  * [counterparty_ruby's rubydoc](http://www.rubydoc.info/github/brighton36/counterparty_ruby/master), 
  * [The Counterparty official API guide](http://counterparty.io/docs/api/).

#### Find the first burn
Here we retrieve burns from the blockchain using ActiveRecord style method calls.

  ```ruby
  require 'counterparty_ruby'

  Counterparty.production!

  burns = Counterparty::Burn.find order_by: 'tx_hash', order_dir: 'asc', 
    start_block: 280537, end_block: 280539

  puts "First burned via: %s" % burns.first.source
  # => 1ADpYypUcnbezuuYpCyRCY7G4KD6a9YXiF
  ```

#### Find the first burn (Alternative API-like syntax)
This example achieves the same outcome as the above example, but uses a more 
json-esque call syntax.

  ```ruby
  require 'counterparty_ruby'

  # This connects to production mode on localhost:
  production = Counterparty.connection.new 4000

  # Note that we follow the api reference for calls here:
  burns = production.get_burns order_by: 'tx_hash', order_dir: 'asc', 
    start_block: 280537, end_block: 280539

  puts "First burned via: %s" % burns.first.source
  # => 1ADpYypUcnbezuuYpCyRCY7G4KD6a9YXiF
  ```

#### Create an Issuance
Here we create an asset and persist that asset intothe blockchain using ActiveRecord style method calls.

  ```ruby
  require 'counterparty_ruby'

  # Note that we default to test mode. Too, this example requires that your 
  # private key for this address exists in the counterparty server's bitcoind 
  first_asset = Counterparty::Issuance.new( 
    source: 'msCXwsPVbv1Q1pc5AjXd5TdVwy3a1fSYB2',
    asset: 'MYFIRSTASSET', 
    description: "Its party time!",
    divisible: false,
    quantity: 100 )

  transaction_id = first_asset.save!('private-key-here')

  puts "Transaction %s has been entered into the mempool" % transaction_id
  ```

#### Create an Issuance (Alternative API-like syntax)
This example achieves the same outcome as the above example, but uses a more 
json-esque call syntax.

  ```ruby
  require 'counterparty_ruby'

  # Note that we default to test mode. Too, this example requires that your 
  # private key for this address exists in the counterparty server's bitcoind 
  transaction_id = Counterparty.connection.do_issuance(
    source: 'msCXwsPVbv1Q1pc5AjXd5TdVwy3a1fSYB2',
    asset: 'MYFIRSTASSET', 
    description: "Its party time!",
    divisible: false,
    quantity: 100 )

  puts "Transaction %s has been entered into the mempool" % transaction_id
  ```

#### Broadcast the outcome of an event
If you're the oracle, tasked with resolving a bet, here's how you would announce
an outcome to the network.

  ```ruby
  require 'counterparty_ruby'

  gold_down = Counterparty::Broadcast.new(
    source: 'msCXwsPVbv1Q1pc5AjXd5TdVwy3a1fSYB2', 
    fee_fraction: 0.05,
    text: "Price of gold, 12AM UTC March1. 1=inc 2=dec/const", 
    timestamp: 1418926641, 
    value: 2 )

  # Note that in this example, we're passing the private key that corresponds 
  # to the public key. This allows us to sign transactions without having to  
  # import the key onto the server's bitcoind. Note that this (currently) does 
  # pass the key to the counterpartyd server. This behavior may change in later
  # versions.
  tx_id = gold_down.save! 'cP7ufwcbZujaa1qkKthLbVZUaP88RS5r9awyXerJE5rAEMTRVmzc'

  puts "Gold was broadcast down in transaction  %s" % tx_id
  ```
#### Broadcast a Feed, Place Bets, Resolve the Bet
In this example, we declare a bet that open, and have two people bet each other
on the outcome. The bet is then resolved.


  ```ruby
  require 'counterparty_ruby'
  require 'active_support/time'
  require "active_support/core_ext/numeric/time"

  TEAM_BLUE_WINS = 1
  TEAM_RED_WINS = 2

  ALICE_ADDRESS = 'n4m2u8GwmFB8VDE1szCTkX5ikEEQLiR2Kj'
  JOHN_ADDRESS = 'mu23MfDNhYmQkJF36aJZ783dLDMrqUi9Fa'

  ORACLE_ADDRESS = 'msCXwsPVbv1Q1pc5AjXd5TdVwy3a1fSYB2'

  Counterparty.test!

  broadcast_text = "Winner of game, %s. %s=red %s=blue" % [
    Time.now.strftime("%I%p %Z %b%-d"), TEAM_RED_WINS, TEAM_BLUE_WINS]

  # Announce the availability of a Bet:
  # NOTE: All times are in UTC
  tx_init = Counterparty::Broadcast.new( source: ORACLE_ADDRESS, 
    value: Counterparty::Broadcast::OPEN_BROADCAST, timestamp: Time.now.to_i,
    text: broadcast_text, fee_fraction: 0.00, allow_unconfirmed_inputs: true ).save!('private-key-here')

  # Alice Bets on Blue:
  tx_bet_on_blue = Counterparty::Bet.new(source: ALICE_ADDRESS, 
    feed_address: ORACLE_ADDRESS, bet_type: Counterparty::Bet::EQUAL, 
    deadline: 10.minutes.from_now.to_i, wager_quantity: 5, 
    counterwager_quantity: 1, expiration: 5, 
    target_value: TEAM_BLUE_WINS, leverage: Counterparty::Bet::LEVERAGE_BASIS,
    allow_unconfirmed_inputs: true ).save!('private-key-here')

  puts "Alice on Blue: %s" % tx_bet_on_blue

  # John Bets on Red:
  tx_bet_on_red = Counterparty::Bet.new(source: JOHN_ADDRESS, 
    feed_address: ORACLE_ADDRESS, bet_type: Counterparty::Bet::EQUAL, 
    deadline: 10.minutes.from_now.to_i, wager_quantity: 5, 
    counterwager_quantity: 1, expiration: 5,
    target_value: TEAM_RED_WINS, leverage: Counterparty::Bet::LEVERAGE_BASIS,
    allow_unconfirmed_inputs: true ).save!('private-key-here')

  puts "John on Red: %s" % tx_bet_on_red

  # Close the broadcast : Team Blue wins!
  tx_outcome = Counterparty::Broadcast.new( source: ORACLE_ADDRESS, 
    value: TEAM_BLUE_WINS, timestamp: 20.minutes.from_now.to_i, 
    fee_fraction: 0.00,
    text: broadcast_text, allow_unconfirmed_inputs: true ).save!('private-key-here')

  puts "Oracle says: %s" % tx_outcome

  ```
#### Compile, Publish and Execute a Serpent Contract
This is still beta behavior, and only supported on testnet, but here's a quick
example of how Smart Contracts are published and executed. Note that we require
the serpent CLI executable is installed on the running system

  ```ruby
  require 'open3'
  require 'counterparty_ruby'

  class Serpent
    # Be sure to use the version from : https://github.com/ethereum/pyethereum
    SERPENT='/usr/local/bin/serpent'

    def compile(contract)
      serpent 'compile', '-s', :stdin_data => contract
    end

    def encode_datalist(data)
      serpent 'encode_datalist', data
    end

    private

    def serpent(*args)
      options = (args.last.kind_of? Hash) ? args.pop : {}
      stdout, status = Open3.capture2( ([SERPENT]+args).join(' '), options)

      raise StandardError, "Compile Failed: %s" % status.exitstatus unless status.success?

      stdout.chomp
    end
  end

  SOURCE_ADDRESS="msCXwsPVbv1Q1pc5AjXd5TdVwy3a1fSYB2"

  Counterparty.test!

  serpent = Serpent.new

  compiled_script = serpent.compile <<-eos
    return(msg.data[0]*2)
  eos

  contract_id = Counterparty::Publish.new( source: SOURCE_ADDRESS, 
    code_hex: compiled_script, gasprice: 1, startgas: 1000000, endowment: 0, 
    allow_unconfirmed_inputs: true ).save!('private-key-here')

  datalist = serpent.encode_datalist '53'

  execute_id = Counterparty::Execute.new( source: SOURCE_ADDRESS, 
    contract_id: contract_id, payload_hex: datalist, gasprice: 5, 
    startgas: 160000, value: 10, allow_unconfirmed_inputs: true ).save!('private-key-here')

  puts "Executed Transaction ID: %s" % execute_id
  ```

## Have questions?
The _best_ place to start is the [Counterparty API reference](http://counterparty.io/docs/api/).
You'll soon find that this gem is merely a wrapper around the official 
counterpartyd json API.

But, if that doesn't help tweet [@derosetech](https://twitter.com/derosetech) 
and/or check the [Counterparty Forums](https://forums.counterparty.io/) for more 
help from the community. 

We appreciate your patience if you're having problems, please bear in mind that 
we're in active development mode. And thank-you for using Counterparty!

![Best Party Ever](http://www.quickmeme.com/img/c8/c8cc224c5b1e8b1baafeba4287d9534add53273bc79572a5fcc8ab8ab2cc19ab.jpg)
