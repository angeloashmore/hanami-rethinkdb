require 'rubygems'
require 'bundler/setup'

require 'minitest/autorun'
$LOAD_PATH.unshift 'lib'
require 'lotus-rethinkdb'

include RethinkDB::Shortcuts

RETHINKDB_TEST_CONNECTION = r.connect

def run
  yield.run(RETHINKDB_TEST_CONNECTION)
end

begin
  run { r.table_create('test_users') }
rescue RethinkDB::RqlRuntimeError => _e
  puts 'Table `test_users` already exists'
end

begin
  run { r.table_create('test_devices') }
rescue RethinkDB::RqlRuntimeError => _e
  puts 'Table `test_devices` already exists'
end

run { r.table('test_users').delete }
run { r.table('test_devices').delete }
