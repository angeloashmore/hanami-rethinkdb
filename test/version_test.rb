require 'test_helper'

describe Hanami::Rethinkdb::VERSION do
  it 'returns current version' do
    Hanami::Rethinkdb::VERSION.must_equal '0.2.3'
  end
end
