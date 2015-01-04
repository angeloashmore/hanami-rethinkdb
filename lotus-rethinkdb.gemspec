# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lotus/rethinkdb/version'

Gem::Specification.new do |spec|
  spec.name          = 'lotus-rethinkdb'
  spec.version       = Lotus::Rethinkdb::VERSION
  spec.authors       = ['Angelo Ashmore']
  spec.email         = ['angeloashmore@gmail.com']
  spec.summary       = %q{RethinkDB adapter for Lotus::Model}
  spec.description   = %q{RethinkDB adapter for Lotus::Model}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split("\n")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'lotus-model', '~> 0.2'
  spec.add_runtime_dependency 'rethinkdb',   '~> 1.15'

  spec.add_development_dependency 'bundler',       '~> 1.7'
  spec.add_development_dependency 'minitest',      '~> 5.5'
  spec.add_development_dependency 'minitest-line', '~> 0.6.2'
  spec.add_development_dependency 'rake',          '~> 10.0'
end
