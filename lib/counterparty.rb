require 'counterparty/version'

module Counterparty
  class Client
    attr_accessor :host, :port, :username, :password

    def initialize(host='localhost', port=4000, username='rpc', password='1234')
      @host,@port,@username,@password=host,port,username,password
    end
  end
end
