require 'test_helper'

describe Lotus::Rethinkdb::VERSION do
  it 'returns current version' do
    Lotus::Rethinkdb::VERSION.must_equal '0.1.0'
  end
end
