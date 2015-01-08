require 'test_helper'

describe Lotus::Model::Adapters::Rethinkdb::VERSION do
  it 'returns current version' do
    Lotus::Model::Adapters::Rethinkdb::VERSION.must_equal '0.1.1'
  end
end
