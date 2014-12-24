counterparty_ruby
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

[Party on Wayne! (Party on Garth!)](https://www.youtube.com/watch?v=g-CFIO-fCt8)

## Examples
Documentation on the objects is available via ruby-doc, but a better guide to
getting started is available on [counterparty's official API guide](https://github.com/CounterpartyXCP/counterpartyd/blob/master/docs/API.rst#read-api-function-reference).

#### Find the first burn (Active Record Syntax):
```ruby
gem 'counterparty_ruby'

Counterparty.production!

burns = Counterparty::Burn.find order_by: 'tx_hash', order_dir: 'asc', 
  start_block: 280537, end_block: 280539

puts "First burned via: %s" % burns.first.source
# => 1ADpYypUcnbezuuYpCyRCY7G4KD6a9YXiF
```

#### Find the first burn (Alternative API-like syntax)
```ruby
gem 'counterparty_ruby'

# This connects to production mode on localhost:
production = Counterparty.connection.new 4000

# Note that we follow the api reference for calls here:
burns = production.get_burns order_by: 'tx_hash', order_dir: 'asc', 
  start_block: 280537, end_block: 280539

puts "First burned via: %s" % burns.first.source
# => 1ADpYypUcnbezuuYpCyRCY7G4KD6a9YXiF
```

#### Create an Issuance
```ruby
gem 'counterparty_ruby'

# Note that we default to test mode. Too, this example requires that your 
# private key for this address exists in the counterparty server's bitcoind 
first_asset = Counterparty::Issuance.new( 
  source: 'msCXwsPVbv1Q1pc5AjXd5TdVwy3a1fSYB2',
  asset: 'MYFIRSTASSET', 
  description: "Its party time!",
  divisible: false,
  quantity: 100 )

transaction_id = first_asset.save!                                          

puts "Transaction %s has been entered into the mempool" % transaction_id
```

#### Create an Issuance (Alternative API-like syntax)
```ruby
gem 'counterparty_ruby'

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

## Have questions?
The *best* place to start is the [Counterparty API reference](https://github.com/CounterpartyXCP/counterpartyd/blob/master/docs/API.rst#read-api-function-reference).
You'll soon find that this gem is merely a wrapper around the official 
counterpartyd json API.

But, if that doesn't help tweet @derosetech and/or check the 
(Counterparty Forums)[https://forums.counterparty.io/] for more help from the
community. 

We appreciate your patience if you're having problems, please bear in mind that 
we're in active development mode. And thank-you for using Counterparty!
