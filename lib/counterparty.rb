require 'json'
require 'rest_client'
require 'counterparty/version'
require 'counterparty/read_requests'
require 'counterparty/client'

module Counterparty
  class JsonResponseError < StandardError; end
end
