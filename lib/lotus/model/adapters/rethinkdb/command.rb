module Lotus
  module Model
    module Adapters
      module Rethinkdb
        # Execute a command for the given query.
        #
        # @see Lotus::Model::Adapters::Rethinkdb::Query
        #
        # @api private
        # @since 0.1.0
        class Command
          # Initialize a command
          #
          # @param query [Lotus::Model::Adapters::Rethinkdb::Query]
          #
          # @api private
          # @since 0.1.0
          def initialize(query)
            @collection = query.scoped
          end

          # Creates a document for the given entity.
          #
          # @param entity [Object] the entity to persist
          #
          # @see Lotus::Model::Adapters::Rethinkdb::Collection#insert
          #
          # @return the primary key of the just created document.
          #
          # @api private
          # @since 0.1.0
          def create(entity)
            @collection.insert(entity)
          end

          # Updates the corresponding document for the given entity.
          #
          # @param entity [Object] the entity to persist
          #
          # @see Lotus::Model::Adapters::Rethinkdb::Collection#update
          #
          # @api private
          # @since 0.1.0
          def update(entity)
            @collection.update(entity)
          end

          # Deletes all the documents for the current query.
          #
          # It's used to delete a single document or an entire database table.
          #
          # @see Lotus::Model::Adapters::RethinkdbAdapter#delete
          # @see Lotus::Model::Adapters::RethinkdbAdapter#clear
          #
          # @api private
          # @since 0.1.0
          def delete
            @collection.delete
          end

          alias_method :clear, :delete

          # Returns an unique record from the given collection with the given
          # id.
          #
          # @param key [Array] the identity of the object
          #
          # @see Lotus::Model::Adapters::Rethinkdb::Collection#get
          #
          # @return [Object] the entity
          #
          # @api private
          # @since 0.1.0
          def get(id)
            @collection.get(id)
          end

          alias_method :find, :get
        end
      end
    end
  end
end
