require 'rubygems'
require 'bundler/setup'

require 'minitest/autorun'
$:.unshift 'lib'
require 'lotus-rethinkdb'

include RethinkDB::Shortcuts

RETHINKDB_TEST_CONNECTION = r.connect

r.table('test_users').delete.run(RETHINKDB_TEST_CONNECTION)
r.table('test_devices').delete.run(RETHINKDB_TEST_CONNECTION)
