# File: Rakefile

require 'rake'
require 'rake/packagetask'
require 'rdoc/task'
require 'rspec/core/rake_task'

spec = Gem::Specification.load('counterparty_ruby.gemspec')

RDOC_FILES = FileList["README.md", "lib/*.rb", "lib/counterparty/*.rb"]

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_dir = "doc/site/api"
  rd.rdoc_files.include(RDOC_FILES)
end

Rake::RDocTask.new(:ri) do |rd|
  rd.main = "README.md"
  rd.rdoc_dir = "doc/ri"
  rd.options << "--ri-system"
  rd.rdoc_files.include(RDOC_FILES)
end

RSpec::Core::RakeTask.new('spec')

task :spec => :compile

