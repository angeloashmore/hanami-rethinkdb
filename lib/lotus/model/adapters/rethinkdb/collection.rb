require 'delegate'
require 'active_support/core_ext/hash/indifferent_access'
require 'rethinkdb'

module Lotus
  module Model
    module Adapters
      module Rethinkdb
        # Maps a RethinkDB database table and perfoms manipulations on it.
        #
        # @api private
        # @since 0.1.0
        class Collection < SimpleDelegator
          include RethinkDB::Shortcuts

          # Initialize a collection
          #
          # @param connection [RethinkDB::Connection] the connection to the
          #   database
          # @param dataset [RethinkDB::RQL] the dataset that maps a table or a
          #   subset of it.
          # @param mapped_collection [Lotus::Model::Mapping::Collection] a
          #   mapped collection
          #
          # @return [Lotus::Model::Adapters::Rethinkdb::Collection]
          #
          # @api private
          # @since 0.1.0
          def initialize(connection, dataset, mapped_collection)
            super(dataset)
            @connection, @mapped_collection = connection, mapped_collection
          end

          # Creates a document for the given entity and assigns an id.
          #
          # @param entity [Object] the entity to persist
          #
          # @see Lotus::Model::Adapters::Rethinkdb::Command#create
          #
          # @return the primary key of the created document
          #
          # @api private
          # @since 0.1.0
          def insert(entity)
            response = _run do
              super(_serialize(entity))
            end

            response['generated_keys'].first
          end

          # Updates the document corresponding to the given entity.
          #
          # @param entity [Object] the entity to persist
          #
          # @see Lotus::Model::Adapters::Rethinkdb::Command#update
          #
          # @api private
          # @since 0.1.0
          def update(entity)
            _run do
              super(_serialize(entity))
            end
          end

          # Deletes the current scope.
          #
          # @see Lotus::Model::Adapters::Rethinkdb::Command#delete
          #
          # @api private
          # @since 0.1.0
          def delete
            _run do
              super
            end
          end

          # Filters the current scope with a `filter` directive.
          #
          # @param args [Array] the array of arguments
          #
          # @see Lotus::Model::Adapters::Rethinkdb::Query#where
          #
          # @return [Lotus::Model::Adapters::Rethinkdb::Collection] the filtered
          #   collection
          #
          # @api private
          # @since 0.1.0
          def filter(*args)
            _collection(super, @mapped_collection)
          end

          # Filters the current scope with a `pluck` directive.
          #
          # @param args [Array] the array of arguments
          #
          # @see Lotus::Model::Adapters::Rethinkdb::Query#pluck
          #
          # @return [Lotus::Model::Adapters::Rethinkdb::Collection] the filtered
          #   collection
          #
          # @api private
          # @since 0.1.0
          def pluck(*args)
            _collection(super, @mapped_collection)
          end

          # Filters the current scope with a `limit` directive.
          #
          # @param args [Array] the array of arguments
          #
          # @see Lotus::Model::Adapters::Rethinkdb::Query#limit
          #
          # @return [Lotus::Model::Adapters::Rethinkdb::Collection] the filtered
          #   collection
          #
          # @api private
          # @since 0.1.0
          def limit(*args)
            _collection(super, @mapped_collection)
          end

          # Filters the current scope with an `order_by` directive.
          #
          # @param args [Array] the array of arguments
          #
          # @see Lotus::Model::Adapters::Rethinkdb::Query#order
          # @see Lotus::Model::Adapters::Rethinkdb::Query#desc
          #
          # @return [Lotus::Model::Adapters::Rethinkdb::Collection] the filtered
          #   collection
          #
          # @api private
          # @since 0.1.0
          def order_by(*args)
            _collection(super, @mapped_collection)
          end

          # Resolves self by fetching the documents from the database and
          # translating them into entities.
          #
          # @return [Array] the result of the query
          #
          # @api private
          # @since 0.1.0
          def to_a
            _deserialize(
              _run do
                self
              end
            )
          end

          alias_method :execute, :to_a

          private

          # Serialize the given entity before to persist in the database.
          #
          # @return [Hash] the serialized entity
          #
          # @api private
          # @since 0.1.0
          def _serialize(entity)
            @mapped_collection.serialize(entity)
          end

          # Deserialize a set of documents fetched from the database.
          #
          # @note ActiveSupport's HashWithIndifferentAccess is used to solve an
          #   incompatability between Lotus::Model's use of symbols and
          #   RethinkDB's use of strings.
          #
          # @param documents [Array] a set of raw documents
          #
          # @api private
          # @since 0.1.0
          def _deserialize(documents)
            @mapped_collection.deserialize(
              documents.map(&:with_indifferent_access)
            )
          end

          # Returns a collection with the connection automatically included.
          #
          # @return [Lotus::Model::Adapters::Rethinkdb::Collection]
          #
          # @api private
          # @since 0.1.0
          def _collection(*args)
            Collection.new(@connection, *args)
          end

          # Run the enclosed block on the database.
          #
          # @api private
          # @since 0.1.0
          def _run
            yield.run(@connection)
          end
        end
      end
    end
  end
end
