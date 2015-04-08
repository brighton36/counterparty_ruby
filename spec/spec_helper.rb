$:<< File.join(File.dirname(__FILE__), '..','lib')

require 'yaml'
require 'rspec/its'
require 'counterparty_ruby'

def config_yaml
  YAML.load File.open([File.dirname(__FILE__),'config.yml'].join('/')).read
end

def connection(env)
  config = config_yaml[env]
  %w(port username password host).collect{ |a| config[a] }
end

shared_context 'globals' do
  let(:config){ config_yaml }

  let(:source_address) { config['source_address'] }
  let(:source_privkey) { config['source_privkey'] }
  let(:destination_address) { config['spend_destination'] }

  # Since asset names have to be unique, we try our best to create a unique
  # one here. This asset is composed of the timestamp, plus the machine
  # name we're running on. Be advised this might be a small privacy breach 
  # forsensitive operations.
  # There might be some collisions here due to my not handling fixed-width
  # integers greater than 26. I don't think I care about that right now
  let!(:unique_asset_name) do
    base26_time = Time.now.strftime('%y %m %d %H %M %S').split(' ').collect{|c| c.to_i.to_s(26)}
    alpha_encode = base26_time.join.tr((('0'..'9').to_a+('a'..'q').to_a).join, ('A'..'Z').to_a.join)

    [alpha_encode,`hostname`.upcase.tr('^A-Z','')].join[0...12]
  end
end

