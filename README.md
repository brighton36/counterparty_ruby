counterparty_ruby
=================
A ruby gem for communicating with a Counterparty (Bitcoin / XCP) API server.

This gem is designed to abstract communications with the counterpartyd api server in an ActiveRecord-esque object model

## Examples
Documentation on the objects is available via ruby-doc, but a better guide to
getting started is available on [counterparty's official API guide](https://github.com/CounterpartyXCP/counterpartyd/blob/master/docs/API.rst#read-api-function-reference).

### Find the first burn (Active Record Syntax):
```ruby
gem 'counterparty_ruby'

Counterparty.production!

burns = Counterparty::Burn.find order_by: 'tx_hash', order_dir: 'asc', 
  start_block: 280537, end_block: 280539

puts "First burned via: %s" % burns.first.source
# => 1ADpYypUcnbezuuYpCyRCY7G4KD6a9YXiF
```

### Find the first burn (Alternative API-like syntax)
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

## Have questions?
TODO..
