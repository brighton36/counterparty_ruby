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

  def getrawtransaction(tx_id)
    json_get('tx', 'raw', tx_id.to_s)['data']['tx']['hex']
  end

  def sendrawtransaction(raw_tx)
    request('tx', 'push'){|req| req.post( {hex: raw_tx}.to_json, 
      accept: 'json', content_type: 'json' ) }['data']
  end

  def is_testing?
    @is_testing
  end

  def listunspent(addr, include_unconfirmed = false)
    query = [addr,(include_unconfirmed) ? '?unconfirmed=1' : nil ].join
    json_get('address', 'unspent', query)['data']['unspent']
  end

  # Shows all the transactions that are unconfirmed for the provided address:
  def listunconfirmed(addr)
    json_get('address','unconfirmed',addr)['data']['unconfirmed']
  end

  private

  def request(*path, &block)
    json = JSON.parse(block.call(client(*path)))
    raise ResponseError unless json['status'] == 'success' && json['code'] == 200
    json
  end

  def client(*path_parts)
     RestClient::Resource.new( ([api_url]+path_parts).join('/') )
  end

  def json_get(*path)
    request(*path){ |req| req.get content_type: 'json' }
  end
end
