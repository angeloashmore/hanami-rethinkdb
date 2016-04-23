require 'forwardable'
require 'hanami/utils/kernel'
require 'rethinkdb'

module Hanami
  module Model
    module Adapters
      module Rethinkdb
        # Query the database with a powerful API.
        #
        # All the methods are chainable, it allows advanced composition of
        # ReQL conditions.
        #
        # This works as a lazy filtering mechanism: the documents are fetched
        # from the database only when needed.
        #
        # @example
        #
        #   query.where(language: 'ruby')
        #        .and(framework: 'hanami')
        #        .desc(:users_count).all
        #
        #   # the documents are fetched only when we invoke #all
        #
        # It implements Ruby's `Enumerable` and borrows some methods from
        # `Array`. Expect a query to act like them.
        #
        # @since 0.1.0
        class Query
          include RethinkDB::Shortcuts
          include Enumerable
          extend Forwardable

          def_delegators :all, :each, :to_s, :empty?

          # @attr_reader conditions [Array] an accumulator for the called
          #   methods
          #
          # @since 0.1.0
          # @api private
          attr_reader :conditions

          # Initialize a query
          #
          # @param collection [Hanami::Model::Adapters::Rethinkdb::Collection]
          #   the collection to query
          #
          # @param blk [Proc] an optional block that gets yielded in the
          #   context of the current query
          #
          # @return [Hanami::Model::Adapters::Rethinkdb::Query]
          def initialize(collection, context = nil, &blk)
            @collection, @context = collection, context
            @conditions = []

            instance_eval(&blk) if block_given?
          end

          # Resolves the query by fetching documents from the database and
          # translating them into entities.
          #
          # @return [Array] a collection of entities
          #
          # @since 0.1.0
          def all
            scoped.execute
          end

          # Adds a condition like SQL `WHERE` using r.filter().
          #
          # It accepts a `Hash` with only one pair.
          # The key must be the name of the field expressed as a `Symbol`.
          # The value is the one used by the ReQL query
          #
          # @param condition [Hash]
          #
          # @return self
          #
          # @since 0.1.0
          #
          # @example Fixed value
          #
          #   query.where(language: 'ruby')
          #
          #   # => r.filter(language: 'ruby')
          #
          # @example Multiple conditions
          #
          #   query.where(language: 'ruby')
          #        .where(framework: 'hanami')
          #
          #   # => r.filter(language: 'ruby').filter('framework: 'hanami')
          #
          # @example Blocks
          #
          #   query.where { |doc| doc['age'] > 10 }
          #
          #   # => r.filter { |doc| doc.bracket('age').gt('10') }
          def where(condition = nil, &blk)
            condition = condition || blk ||
                        fail(ArgumentError, 'You need to specify a condition.')
            conditions.push([:filter, condition])
            self
          end

          alias_method :and, :where

          # Pluck only the specified fields. Documents without the fields are
          # omitted.
          #
          # By default a query includes all the fields of a table.
          #
          # @param fields [Array<Symbol>]
          #
          # @return self
          #
          # @since 0.1.0
          #
          # @example Single field
          #
          #   query.pluck(:name)
          #
          #   # => r.pluck(:name)
          #
          # @example Multiple fields
          #
          #   query.pluck(:name, :year)
          #
          #   # => r.pluck(:name, :year)
          def pluck(*fields)
            conditions.push([:pluck, *fields])
            self
          end

          # Only include documents with the given fields.
          #
          # @param fields [Array<Symbol>]
          #
          # @return self
          #
          # @since 0.1.0
          #
          # @example Single column
          #
          #   query.has_fields(:name)
          #
          #   # => r.has_fields(:name)
          #
          # @example Multiple columns
          #
          #   query.has_fields(:name, :year)
          #
          #   # => r.has_fields(:name, :year)
          def has_fields(*fields) # rubocop:disable Style/PredicateName
            conditions.push([:has_fields, *fields])
            self
          end

          # Limit the number of documents to return.
          #
          # This operation is performed at the database level with r.limit().
          #
          # @param number [Fixnum]
          #
          # @return self
          #
          # @since 0.1.0
          #
          # @example
          #
          #   query.limit(1)
          #
          #   # => r.limit(1)
          def limit(number)
            conditions.push([:limit, number])
            self
          end

          # Specify the ascending order of the documents, sorted by the given
          # fields or index. Identify an index using `{ index: :key }`.
          #
          # The last invokation of this method takes precidence. Previously
          # called sorts will be overwritten by RethinkDB.
          #
          # @param fields [Array<Symbol, Hash>] the field names, optionally with
          #   an index identifier
          #
          # @return self
          #
          # @since 0.1.0
          #
          # @see Hanami::Model::Adapters::Rethinkdb::Query#desc
          #
          # @example Single field
          #
          #   query.order(:name)
          #
          #   # => r.order_by(:name)
          #
          # @example Multiple columns
          #
          #   query.order(:name, :year)
          #
          #   # => r.order_by(:name, :year)
          #
          # @example Single index
          #
          #   query.order(index: :date)
          #
          #   # => r.order_by(index: :date)
          #
          # @example Mixed fields and index
          #
          #   query.order(:name, :year, index: :date)
          #
          #   # => r.order_by(:name, :year, index: :date)
          def order(*fields)
            conditions.push([:order_by, *fields])
            self
          end

          alias_method :asc, :order

          # Specify the descending order of the documents, sorted by the given
          # fields or index. Identify an index using `{ index: :key }`.
          #
          # The last invokation of this method takes precidence. Previously
          # called sorts will be overwritten by RethinkDB.
          #
          # @return self
          #
          # @since 0.1.0
          #
          # @see Hanami::Model::Adapters::Rethinkdb::Query#desc
          #
          # @example Single field
          #
          #   query.desc(:name)
          #
          #   # => r.order_by(r.desc(:name))
          #
          # @example Multiple columns
          #
          #   query.desc(:name, :year)
          #
          #   # => r.order_by(r.desc(:name), r.desc(:year))
          #
          # @example Single index
          #
          #   query.desc(index: :date)
          #
          #   # => r.order_by(index: r.desc(:date))
          #
          # @example Mixed fields and index
          #
          #   query.desc(:name, :year, { index: r.desc(:date) })
          #
          #   # => r.order_by(r.desc(:name), r.desc(:year), { index:
          #                   r.desc(:date) })
          def desc(*fields)
            conditions.push([:order_by, *_desc_wrapper(*fields)])
            self
          end

          # Returns the sum of the values for the given field.
          #
          # @param field [Symbol] the field name
          #
          # @return [Numeric]
          #
          # @since 0.1.0
          #
          # @example
          #
          #    query.sum(:comments_count)
          #
          #    # => r.sum(:comments_count)
          def sum(field)
            scoped.sum(field)
          end

          # Returns the average of the values for the given field.
          #
          # @param field [Symbol] the column name
          #
          # @return [Numeric]
          #
          # @since 0.1.0
          #
          # @example
          #
          #    query.average(:comments_count)
          #
          #    # => r.avg(:comments_count)
          def average(field)
            scoped.avg(field)
          end

          alias_method :avg, :average

          # Returns the maximum value for the given field.
          #
          # @param field [Symbol] the field name
          #
          # @return result
          #
          # @since 0.1.0
          #
          # @example With numeric type
          #
          #    query.max(:comments_count)
          #
          #    # r.max(:comments_count)
          #
          # @example With string type
          #
          #    query.max(:title)
          #
          #    # => r.max(:title)
          def max(field)
            has_fields(field)
            scoped.max(field)
          end

          # Returns the minimum value for the given field.
          #
          # @param field [Symbol] the field name
          #
          # @return result
          #
          # @since 0.1.0
          #
          # @example With numeric type
          #
          #    query.min(:comments_count)
          #
          #    # => r.min(:comments_count)
          #
          # @example With string type
          #
          #    query.min(:title)
          #
          #    # => r.min(:title)
          def min(field)
            has_fields(field)
            scoped.min(field)
          end

          # Returns a count of the records for the current conditions.
          #
          # @return [Fixnum]
          #
          # @since 0.1.0
          #
          # @example
          #
          #    query.where(author_id: 23).count # => 5
          def count
            scoped.count
          end

          # Apply all the conditions and returns a filtered collection.
          #
          # This operation is idempotent, and the returned result didn't
          # fetched the documents yet.
          #
          # @return [Hanami::Model::Adapters::Rethinkdb::Collection]
          #
          # @since 0.1.0
          def scoped
            scope = @collection

            conditions.each do |(method, *args)|
              scope = scope.public_send(method, *args)
            end

            scope
          end

          protected

          # Handles missing methods for query combinations
          #
          # @api private
          # @since 0.1.0
          #
          # @see Hanami::Model::Adapters:Rethinkdb::Query#apply
          def method_missing(m, *args, &blk)
            if @context.respond_to?(m)
              apply @context.public_send(m, *args, &blk)
            else
              super
            end
          end

          private

          # Returns a new query that is the result of the merge of the current
          # conditions with the ones of the given query.
          #
          # This is used to combine queries together in a Repository.
          #
          # @param query [Hanami::Model::Adapters::Rethinkdb::Query] the query
          #   to apply
          #
          # @return [Hanami::Model::Adapters::Rethinkdb::Query] a new query with
          #   the merged conditions
          #
          # @api private
          # @since 0.1.0
          #
          # @example
          #   require 'hanami/model'
          #
          #   class ArticleRepository
          #     include Hanami::Repository
          #
          #     def self.by_author(author)
          #       query do
          #         where(author_id: author.id)
          #       end
          #     end
          #
          #     def self.rank
          #       query.desc(:comments_count)
          #     end
          #
          #     def self.rank_by_author(author)
          #       rank.by_author(author)
          #     end
          #   end
          #
          #   # The code above combines two queries: `rank` and `by_author`.
          #   #
          #   # The first class method `rank` returns a `Rethinkdb::Query`
          #   # instance which doesn't respond to `by_author`. How to solve
          #   # this problem?
          #   #
          #   # 1. When we use `query` to fabricate a `Rethinkdb::Query` we
          #   # pass the current context (the repository itself) to the query
          #   # initializer.
          #   #
          #   # 2. When that query receives the `by_author` message, it's
          #   # captured by `method_missing` and dispatched to the repository.
          #   #
          #   # 3. The class method `by_author` returns a query too.
          #   #
          #   # 4. We just return a new query that is the result of the current
          #   # query's conditions (`rank`) and of the conditions from
          #   # `by_author`.
          #   #
          #   # You're welcome ;)
          def apply(query)
            dup.tap do |result|
              result.conditions.push(*query.conditions)
            end
          end

          # Wrap the given fields with a desc operator.
          #
          # @return [Array] the wrapped fields
          #
          # @api private
          # @since 0.1.0
          def _desc_wrapper(*fields)
            Array(fields).map do |field|
              if field.is_a?(Hash)
                field.merge(field) { |_k, v| r.desc(v) }
              else
                r.desc(field)
              end
            end
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
