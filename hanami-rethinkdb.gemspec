# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hanami/rethinkdb/version'

Gem::Specification.new do |spec|
  spec.name          = 'hanami-rethinkdb'
  spec.version       = Hanami::Rethinkdb::VERSION
  spec.authors       = ['Angelo Ashmore']
  spec.email         = ['angeloashmore@gmail.com']
  spec.summary       = 'RethinkDB adapter for Hanami::Model'
  spec.description   = 'RethinkDB adapter for Hanami::Model'
  spec.homepage      = 'https://github.com/angeloashmore/hanami-rethinkdb'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split("\n")
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'hanami-model',   '~> 0.5'
  spec.add_runtime_dependency 'rethinkdb',      '~> 2.2'
  spec.add_runtime_dependency 'activesupport',  '~> 4.2'

  spec.add_development_dependency 'bundler',       '~> 1.6'
  spec.add_development_dependency 'minitest',      '~> 5.8'
  spec.add_development_dependency 'minitest-line', '~> 0.6.3'
  spec.add_development_dependency 'rake',          '~> 11.1'
end
