require 'rethinkdb'
require 'lotus/model/adapters/abstract'
require 'lotus/model/adapters/implementation'
require 'lotus/model/adapters/rethinkdb/coercer'
require 'lotus/model/adapters/rethinkdb/collection'
require 'lotus/model/adapters/rethinkdb/command'
require 'lotus/model/adapters/rethinkdb/query'

module Lotus
  module Model
    module Adapters
      class RethinkdbAdapter < Abstract
        include Implementation
      end
    end
  end
end
