require 'lotus/model/adapters/abstract'
require 'lotus/model/adapters/rethinkdb/collection'
require 'lotus/model/adapters/rethinkdb/command'
require 'lotus/model/adapters/rethinkdb/query'
require 'rethinkdb'

module Lotus
  module Model
    module Adapters
      # Adapter for RethinkDB databases
      #
      # @see Lotus::Model::Adapters::Implementation
      #
      # @api private
      # @since 0.1.0
      class RethinkdbAdapter < Abstract
        include ::RethinkDB::Shortcuts

        # @attr_reader parsed_uri [Hash] the database connection details parsed
        #   from a URI
        #
        # @since 0.1.0
        # @api private
        attr_reader :parsed_uri

        # Initialize the adapter.
        #
        # Lotus::Model uses RethinkDB.
        #
        # @param mapper [Object] the database mapper
        # @param connection [RethinkDB::Connection] the database connection
        #
        # @return [Lotus::Model::Adapters::RethinkdbAdapter]
        #
        # @see Lotus::Model::Mapper
        # @see http://rethinkdb.com/api/ruby/
        #
        # @api private
        # @since 0.1.0
        def initialize(mapper, uri)
          super
          @connection = r.connect(_parse_uri)
        end

        # Creates or updates a document in the database for the given entity.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        # @param entity [#id, #id=] the entity to persist
        #
        # @return [Object] the entity
        #
        # @api private
        # @since 0.1.0
        def persist(collection, entity)
          if entity.id
            update(collection, entity)
          else
            create(collection, entity)
          end
        end

        # Creates a document in the database for the given entity.
        # It assigns the `id` attribute, in case of success.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        # @param entity [#id=] the entity to create
        #
        # @return [Object] the entity
        #
        # @api private
        # @since 0.1.0
        def create(collection, entity)
          entity.id = command(
                        query(collection)
                      ).create(entity)
          entity
        end

        # Updates a document in the database corresponding to the given entity.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        # @param entity [#id] the entity to update
        #
        # @return [Object] the entity
        #
        # @api private
        # @since 0.1.0
        def update(collection, entity)
          command(
            _find(collection, entity.id)
          ).update(entity)
        end

        # Deletes a document in the database corresponding to the given entity.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        # @param entity [#id] the entity to delete
        #
        # @api private
        # @since 0.1.0
        def delete(collection, entity)
          command(
            _find(collection, entity.id)
          ).delete
        end

        # Returns all the documents for the given collection
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        #
        # @return [Array] all the documents
        #
        # @api private
        # @since 0.1.0
        def all(collection)
          query(collection).all
        end

        # Returns a unique document from the given collection, with the given
        # id.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        # @param id [Object] the identity of the object.
        #
        # @return [Object] the entity
        #
        # @api private
        # @since 0.1.0
        def find(collection, id)
          _first(
            _find(collection, id)
          )
        end

        # This method is not implemented. RethinkDB does not have sequential
        # primary keys.
        #
        # @param _collection [Symbol] the target collection (it must be mapped)
        #
        # @raise [NotImplementedError]
        #
        # @since 0.1.0
        def first(_collection)
          fail NotImplementedError
        end

        # This method is not implemented. RethinkDB does not have sequential
        # primary keys.
        #
        # @param _collection [Symbol] the target collection (it must be mapped)
        #
        # @raise [NotImplementedError]
        #
        # @since 0.1.0
        def last(_collection)
          fail NotImplementedError
        end

        # Deletes all the documents from the given collection.
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        #
        # @api private
        # @since 0.1.0
        def clear(collection)
          command(query(collection)).clear
        end

        # Fabricates a command for the given query.
        #
        # @param query [Lotus::Model::Adapters::Rethinkdb::Query] the query
        # object to act on.
        #
        # @return [Lotus::Model::Adapters::Rethinkdb::Command]
        #
        # @see Lotus::Model::Adapters::Rethinkdb::Command
        #
        # @api private
        # @since 0.1.0
        def command(query)
          Rethinkdb::Command.new(query)
        end

        # Fabricates a query
        #
        # @param collection [Symbol] the target collection (it must be mapped).
        # @param blk [Proc] a block of code to be executed in the context of
        #   the query.
        #
        # @return [Lotus::Model::Adapters::Rethinkdb::Query]
        #
        # @see Lotus::Model::Adapters::Rethinkdb::Query
        #
        # @api private
        # @since 0.1.0
        def query(collection, context = nil, &blk)
          Rethinkdb::Query.new(_collection(collection), context, &blk)
        end

        private

        # Sets a parsed URI hash to be used when creating the database
        # connection.
        #
        # @api private
        # @since 0.1.0
        def _parse_uri
          parsed = URI.parse(@uri)
          db = parsed.path.gsub(/^\//, '')

          fail DatabaseAdapterNotFound if parsed.scheme != 'rethinkdb'
          fail "No database specified in #{@uri}" if db.empty? || db.nil?

          {
            auth_key: parsed.password,
            host: parsed.host,
            port: parsed.port || 28_015,
            db: db
          }
        end

        # Returns a collection from the given name.
        #
        # @param name [Symbol] a name of the collection (it must be mapped).
        #
        # @return [Lotus::Model::Adapters::Rethinkdb::Collection]
        #
        # @see Lotus::Model::Adapters::Rethinkdb::Collection
        #
        # @api private
        # @since 0.1.0
        def _collection(name)
          Rethinkdb::Collection.new(
            @connection, r.table(name), _mapped_collection(name)
          )
        end

        def _mapped_collection(name)
          @mapper.collection(name)
        end

        def _find(collection, id)
          identity = _identity(collection)
          query(collection).where(identity => _id(collection, identity, id))
        end

        def _first(query)
          query.limit(1).first
        end

        def _identity(collection)
          _mapped_collection(collection).identity
        end

        def _id(collection, column, value)
          _mapped_collection(collection).deserialize_attribute(column, value)
        end
      end
    end
  end
end
