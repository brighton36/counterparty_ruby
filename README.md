counterparty_ruby
=================
A ruby gem for communicating with a Counterparty (Bitcoin / XCP) API server.

This gem is designed to abstract communications with the counterpartyd api server in an ActiveRecord-esque object model

== Examples

Find the first burn:
  gem 'counterparty_ruby'

  Counterparty.production!

  burns = Counterparty::Burn.find order_by: 'tx_hash', order_dir: 'asc', 
    start_block: 280537, end_block: 280539

  puts "First burned via: %s" % burns.first.source
  # => 1ADpYypUcnbezuuYpCyRCY7G4KD6a9YXiF


