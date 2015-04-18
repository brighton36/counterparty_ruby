# This is a 'driver' meant to emulate bitcoin-client calls, by way of the blockr.io
# API
class BlockrIo
  class ResponseError < StandardError; end

  def initialize(is_testing = false)
    @is_testing = is_testing
  end

  def api_url
    'http://%s.blockr.io/api/v1' % (is_testing? ? 'tbtc' : 'btc')
  end

  def gettransaction(tx_id)
    json_get('tx', 'info', tx_id.to_s)['data']
  end

  def sendrawtransaction(raw_tx)
    # TODO:
    # curl -d '{"hex":"TX_HASH"}' http://btc.blockr.io/api/v1/tx/push
=begin
    client = RestClient::Resource.new api_url, :timeout => @timeout
    request = { method: method, params: params, jsonrpc: '2.0', id: '0' }.to_json
    response = JSON.parse client.post(request,
      user: @username, password: @password, accept: 'json', 
      content_type: 'json' )

    raise JsonResponseError.new response if response.has_key? 'code'
    raise ResponseError.new response['error'] if response.has_key? 'error'

    response['result']
=end
  end

  def is_testing?
    @is_testing
  end

  private

  def json_get(*path_parts)
    url = ([api_url]+path_parts).join('/')
    json = JSON.parse(RestClient.get(url), content_type: 'json')
    raise ResponseError unless json['status'] == 'success' && json['code'] == 200
    json
  end
end
