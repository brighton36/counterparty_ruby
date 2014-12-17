# -*- encoding: utf-8 -*-
require File.expand_path('../lib/counterparty/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Chris DeRose"]
  gem.email         = ["chris@chrisderose.com"]
  gem.description   = %q{TODO}
  gem.summary       = %q{TODO}
  gem.homepage      = "TODO"
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "counterparty_ruby"
  gem.require_paths = ["lib"]
  gem.version       = Counterparty::VERSION
  gem.required_ruby_version = '>= 1.9'
  gem.license       = 'MIT'

  ['rest_client'].each do |dependency|
    gem.add_runtime_dependency dependency
  end
  ['rspec', 'rspec-its', 'rake', 'rdoc'].each do |dependency|
    gem.add_development_dependency dependency
  end
end

