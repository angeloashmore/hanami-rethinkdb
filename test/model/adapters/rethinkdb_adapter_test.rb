require 'test_helper'

describe Hanami::Model::Adapters::RethinkdbAdapter do
  before do
    # rubocop:disable Documentation
    class TestUser
      include Hanami::Entity
      attributes :id, :name, :age
    end

    class TestUserRepository
      include Hanami::Repository
    end

    class TestUserWithDateTime
      include Hanami::Entity
      attributes :id, :name, :age, :created_at
    end

    class TestUserWithDateTimeRepository
      include Hanami::Repository
    end

    class TestDevice
      include Hanami::Entity
      attributes :id
    end

    class TestDeviceRepository
      include Hanami::Repository
    end
    # rubocop:enable Documentation

    @mapper = Hanami::Model::Mapper.new do
      collection :test_users do
        entity TestUser

        attribute :id,   String
        attribute :name, String
        attribute :age,  Integer
      end

      collection :test_devices do
        entity TestDevice

        attribute :id, String
      end
    end.load!

    @adapter = Hanami::Model::Adapters::RethinkdbAdapter.new(@mapper,
                                                             RETHINKDB_TEST_URI)

    @mapper_datetime = Hanami::Model::Mapper.new do
      collection :test_users_datetime do
        entity TestUserWithDateTime

        attribute :id,   String
        attribute :name, String
        attribute :age,  Integer
        attribute :created_at, Hanami::Model::Adapters::Rethinkdb::Now
      end
    end.load!
    @adapter_datetime = Hanami::Model::Adapters::RethinkdbAdapter.new(@mapper_datetime,
                                                                      RETHINKDB_TEST_URI)
  end

  after do
    Object.send(:remove_const, :TestUser)
    Object.send(:remove_const, :TestUserRepository)
    Object.send(:remove_const, :TestUserWithDateTime)
    Object.send(:remove_const, :TestUserWithDateTimeRepository)
    Object.send(:remove_const, :TestDevice)
    Object.send(:remove_const, :TestDeviceRepository)
  end

  let(:collection) { :test_users }

  describe Hanami::Model::Adapters::Rethinkdb::Now do
    before do
      @adapter_date = Hanami::Model::Adapters::RethinkdbAdapter.new(@mapper_datetime,
                                                                    RETHINKDB_TEST_URI)
      @created_at = DateTime.now
      @user       = TestUserWithDateTime.new(created_at: @created_at)

      before_ids  = @adapter_date.all(:test_users_datetime).map(&:id).sort
      @user       = @adapter_date.create(:test_users_datetime, @user)
      @after_ids  = @adapter_date.all(:test_users_datetime).map(&:id).sort

      @rvalue     = Array.new(before_ids << @user.id).sort
    end

    after do
      @adapter_date.clear(:test_users_datetime)
    end

    it 'must do not break @adapter instance' do
      @after_ids.must_equal @rvalue
    end

    it 'store the created_at attribute' do
      user = @adapter_date.find(:test_users_datetime, @user.id)
      user.created_at.to_s.must_equal @created_at.to_s
    end
  end

  describe 'multiple collections' do
    before do
      @adapter.clear(:test_users)
      @adapter.clear(:test_devices)
    end

    it 'create documents' do
      user   = TestUser.new
      device = TestDevice.new

      user   = @adapter.create(:test_users, user)
      device = @adapter.create(:test_devices, device)

      @adapter.all(:test_users).must_equal [user]
      @adapter.all(:test_devices).must_equal [device]
    end
  end

  describe '#persist' do
    describe 'when the given entity is not persisted' do
      let(:entity) { TestUser.new }

      it 'stores the document and assigns an id' do
        result = @adapter.persist(collection, entity)

        result.id.wont_be_nil

        @adapter.find(collection, result.id).must_equal result
      end
    end

    describe 'when the given entity is persisted' do
      before do
        @entity = @adapter.create(collection, entity)
      end

      let(:entity) { TestUser.new }

      it 'updates the document and leaves untouched the id' do
        id = @entity.id
        id.wont_be_nil

        @entity.name = 'L'
        @adapter.persist(collection, @entity)

        @entity.id.must_equal id
        @adapter.find(collection, @entity.id).name.must_equal @entity.name
      end
    end
  end

  describe '#create' do
    let(:entity)    { TestUser.new }
    let(:exception) {
      Hanami::Model::Adapters::RethinkdbIOError
    }

    it 'stores the document and assigns an id' do
      result = @adapter.create(collection, entity)

      result.id.wont_be_nil

      @adapter.find(collection, result.id).must_equal result
    end

    it 'raise an IOError when update a nil entity' do
      err = -> {
        @adapter.create(collection, nil)
      }.must_raise(exception)
    end

  end

  describe '#update' do
    before do
      @entity = @adapter.create(collection, entity)
    end

    let(:entity)    { TestUser.new(id: nil, name: 'L') }
    let(:exception) {
      Hanami::Model::Adapters::RethinkdbIOError
    }

    it 'raise an IOError when update a nil entity' do
      err = -> {
        @adapter.create(collection, nil)
      }.must_raise(exception)
    end


    it 'stores the changes and leave the id untouched' do
      id = @entity.id

      @entity.name = 'MG'
      @adapter.update(collection, @entity)

      @entity.id.must_equal id
      @adapter.find(collection, @entity.id).name.must_equal @entity.name
    end
  end

  describe '#delete' do
    before do
      @adapter.create(collection, entity)
    end

    let(:entity) { TestUser.new }

    it 'removes the given identity' do
      @adapter.delete(collection, entity)
      @adapter.find(collection, entity.id).must_be_nil
    end
  end

  describe '#all' do
    describe 'when no documents are persisted' do
      before do
        @adapter.clear(collection)
      end

      it 'returns an empty collection' do
        @adapter.all(collection).must_be_empty
      end
    end

    describe 'when some documents are persisted' do
      before do
        @adapter.clear(collection)
        @entity = @adapter.create(collection, entity)
      end

      let(:entity) { TestUser.new }

      it 'returns all of them' do
        @adapter.all(collection).must_equal [@entity]
      end
    end
  end

  describe '#find' do
    before do
      @entity = @adapter.create(collection, entity)
    end

    let(:entity) { TestUser.new }

    it 'returns the document by id' do
      @adapter.find(collection, @entity.id).must_equal @entity
    end

    it 'returns nil when the document cannot be found' do
      @adapter.find(collection, 1_000_000_000).must_be_nil
    end

    it 'returns nil when the given id is nil' do
      @adapter.find(collection, nil).must_be_nil
    end
  end

  describe '#first' do
    describe 'when no documents are persisted' do
      before do
        @adapter.clear(collection)
      end

      it 'raises an error' do
        -> { @adapter.first(collection) }.must_raise NotImplementedError
      end
    end

    describe 'when some documents are persisted' do
      before do
        @adapter.clear(:test_users)
        @entity1 = @adapter.create(collection, entity1)
        @entity2 = @adapter.create(collection, entity2)
      end

      let(:entity1) { TestUser.new }
      let(:entity2) { TestUser.new }

      it 'raises an error' do
        -> { @adapter.first(collection) }.must_raise NotImplementedError
      end
    end
  end

  describe '#last' do
    describe 'when no documents are persisted' do
      before do
        @adapter.clear(collection)
      end

      it 'raises an error' do
        -> { @adapter.last(collection) }.must_raise NotImplementedError
      end
    end

    describe 'when some documents are persisted' do
      before do
        @adapter.clear(:test_users)
        @adapter.create(collection, entity1)
        @adapter.create(collection, entity2)
      end

      let(:entity1) { TestUser.new }
      let(:entity2) { TestUser.new }

      it 'raises an error' do
        -> { @adapter.last(collection) }.must_raise NotImplementedError
      end
    end
  end

  describe '#clear' do
    before do
      @adapter.create(collection, entity)
    end

    let(:entity) { TestUser.new }

    it 'removes all the documents' do
      @adapter.clear(collection)
      @adapter.all(collection).must_be_empty
    end
  end

  describe '#query' do
    before do
      @adapter.clear(collection)
    end

    let(:user1) { TestUser.new(name: 'L', age: '32') }
    let(:user2) { TestUser.new(name: 'MG', age: 31) }

    describe 'where' do
      describe 'with an empty collection' do
        it 'returns an empty result set' do
          result = @adapter.query(collection) do
            where(id: 23)
          end.all

          result.must_be_empty
        end
      end

      describe 'with a filled collection' do
        before do
          @user1 = @adapter.create(collection, user1)
          @user2 = @adapter.create(collection, user2)
        end

        it 'returns selected records' do
          id = @user1.id

          query = proc do
            where(id: id)
          end

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1]
        end

        it 'can use multiple where conditions' do
          id   = @user1.id
          name = @user1.name

          query = proc do
            where(id: id).where(name: name)
          end

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1]
        end

        it 'can use multiple where conditions with "and" alias' do
          id   = @user1.id
          name = @user1.name

          query = proc do
            where(id: id).and(name: name)
          end

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1]
        end

        it 'can use a block' do
          age = @user1.age

          query = proc do
            where { |user| user['age'].eq(age) }
          end

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1]
        end

        it 'raises an error if you dont specify condition or block' do
          lambda do
            query = proc do
              where
            end

            @adapter.query(collection, &query).all
          end.must_raise(ArgumentError)
        end
      end
    end

    describe 'pluck' do
      describe 'with an empty collection' do
        it 'returns an empty result' do
          result = @adapter.query(collection) do
            pluck(:age)
          end.all

          result.must_be_empty
        end
      end

      describe 'with a filled collection' do
        before do
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
          @adapter.create(collection, user3)
        end

        let(:user1) { TestUser.new(name: 'L', age: 32) }
        let(:user3) { TestUser.new(name: 'S') }
        let(:users) { [user1, user2, user3] }

        it 'returns the selected columns from all the records' do
          query = proc do
            pluck(:age)
          end

          result = @adapter.query(collection, &query).all

          users.each do |user|
            record = result.find { |r| r.age == user.age }
            record.wont_be_nil
            record.name.must_be_nil
          end
        end

        it 'returns only the select of requested records' do
          name = user2.name

          query = proc do
            where(name: name).pluck(:age)
          end

          result = @adapter.query(collection, &query).all

          record = result.first
          record.age.must_equal(user2.age)
          record.name.must_be_nil
        end

        it 'returns only the multiple select of requested records' do
          name = user2.name

          query = proc do
            where(name: name).pluck(:name, :age)
          end

          result = @adapter.query(collection, &query).all

          record = result.first
          record.name.must_equal(user2.name)
          record.age.must_equal(user2.age)
          record.id.must_be_nil
        end
      end
    end

    describe 'has_fields' do
      describe 'with an empty collection' do
        it 'returns an empty result' do
          result = @adapter.query(collection) do
            has_fields(:age)
          end.all

          result.must_be_empty
        end
      end

      describe 'with a filled collection' do
        before do
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
          @adapter.create(collection, user3)
        end

        let(:user1) { TestUser.new(name: 'L', age: 32) }
        let(:user3) { TestUser.new(name: 'S') }
        let(:users) { [user1, user2, user3] }

        it 'returns documents that have the selected fields' do
          query = proc do
            has_fields(:age)
          end

          result = @adapter.query(collection, &query).all
          result.each do |user|
            user.age.wont_be_nil
          end
        end

        it 'returns only the select of requested records' do
          name = user2.name

          query = proc do
            where(name: name).pluck(:age)
          end

          result = @adapter.query(collection, &query).all
          result.each do |user|
            user.age.wont_be_nil
          end
        end

        it 'returns only the multiple select of requested records' do
          name = user2.name

          query = proc do
            where(name: name).pluck(:name, :age)
          end

          result = @adapter.query(collection, &query).all
          result.each do |user|
            user.age.wont_be_nil
          end
        end
      end
    end

    describe 'order' do
      describe 'with an empty collection' do
        it 'returns an empty result set' do
          result = @adapter.query(collection) do
            order(:id)
          end.all

          result.must_be_empty
        end
      end

      describe 'with a filled collection' do
        before do
          @user1 = @adapter.create(collection, user1)
          @user2 = @adapter.create(collection, user2)
        end

        it 'returns sorted records' do
          query = proc do
            order(:age)
          end

          result = @adapter.query(collection, &query).all
          result.must_equal [@user2, @user1]
        end

        it 'returns sorted records, using multiple columns' do
          query = proc do
            order(:age, :name)
          end

          result = @adapter.query(collection, &query).all
          result.must_equal [@user2, @user1]
        end

        it 'returns sorted records, using multiple invokations' do
          query = proc do
            order(:age).order(:name)
          end

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1, @user2]
        end
      end
    end

    describe 'asc' do
      describe 'with an empty collection' do
        it 'returns an empty result set' do
          result = @adapter.query(collection) do
            asc(:id)
          end.all

          result.must_be_empty
        end
      end

      describe 'with a filled collection' do
        before do
          @user1 = @adapter.create(collection, user1)
          @user2 = @adapter.create(collection, user2)
        end

        it 'returns sorted records' do
          query = proc do
            asc(:age)
          end

          result = @adapter.query(collection, &query).all
          result.must_equal [@user2, @user1]
        end
      end
    end

    describe 'desc' do
      describe 'with an empty collection' do
        it 'returns an empty result set' do
          result = @adapter.query(collection) do
            desc(:age)
          end.all

          result.must_be_empty
        end
      end

      describe 'with a filled collection' do
        before do
          @user1 = @adapter.create(collection, user1)
          @user2 = @adapter.create(collection, user2)
        end

        it 'returns reverse sorted records' do
          query = proc do
            desc(:age)
          end

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1, @user2]
        end

        it 'returns sorted records, using multiple columns' do
          query = proc do
            desc(:age, :name)
          end

          result = @adapter.query(collection, &query).all
          result.must_equal [@user1, @user2]
        end

        it 'returns sorted records, using multiple invokations' do
          query = proc do
            desc(:age).desc(:name)
          end

          result = @adapter.query(collection, &query).all
          result.must_equal [@user2, @user1]
        end
      end
    end

    describe 'limit' do
      describe 'with an empty collection' do
        it 'returns an empty result set' do
          result = @adapter.query(collection) do
            limit(1)
          end.all

          result.must_be_empty
        end
      end

      describe 'with a filled collection' do
        before do
          @user1 = @adapter.create(collection, user1)
          @user2 = @adapter.create(collection, user2)
          @user3 = @adapter.create(collection, TestUser.new(name: user2.name))
        end

        it 'returns only the number of requested records' do
          name = @user2.name

          query = proc do
            where(name: name).limit(1)
          end

          result = @adapter.query(collection, &query).all
          result.length == 1
        end
      end
    end

    describe 'count' do
      describe 'with an empty collection' do
        it 'returns 0' do
          result = @adapter.query(collection) do
            all
          end.count

          result.must_equal 0
        end
      end

      describe 'with a filled collection' do
        before do
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
        end

        it 'returns the count of all the records' do
          query = proc do
            all
          end

          result = @adapter.query(collection, &query).count
          result.must_equal 2
        end

        it 'returns the count from an empty query block' do
          query = proc do
          end

          result = @adapter.query(collection, &query).count
          result.must_equal 2
        end

        it 'returns only the count of requested records' do
          name = user2.name

          query = proc do
            where(name: name)
          end

          result = @adapter.query(collection, &query).count
          result.must_equal 1
        end
      end
    end

    describe 'sum' do
      describe 'with an empty collection' do
        it 'returns 0' do
          result = @adapter.query(collection) do
            all
          end.sum(:age)

          result.must_equal 0
        end
      end

      describe 'with a filled collection' do
        before do
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
          @adapter.create(collection, TestUser.new(name: 'S'))
        end

        it 'returns the sum of all the records' do
          query = proc do
            all
          end

          result = @adapter.query(collection, &query).sum(:age)
          result.must_equal 63
        end

        it 'returns the sum from an empty query block' do
          query = proc {}

          result = @adapter.query(collection, &query).sum(:age)
          result.must_equal 63
        end

        it 'returns only the sum of requested records' do
          name = user2.name

          query = proc do
            where(name: name)
          end

          result = @adapter.query(collection, &query).sum(:age)
          result.must_equal 31
        end
      end
    end

    describe 'average' do
      describe 'with an empty collection' do
        it 'returns nil' do
          result = @adapter.query(collection) do
            all
          end.average(:age)

          result.must_be_nil
        end
      end

      describe 'with a filled collection' do
        before do
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
          @adapter.create(collection, TestUser.new(name: 'S'))
        end

        it 'returns the average of all the records' do
          query = proc do
            all
          end

          result = @adapter.query(collection, &query).average(:age)
          result.must_equal 31.5
        end

        it 'returns the average from an empty query block' do
          query = proc {}

          result = @adapter.query(collection, &query).average(:age)
          result.must_equal 31.5
        end

        it 'returns only the average of requested records' do
          name = user2.name

          query = proc do
            where(name: name)
          end

          result = @adapter.query(collection, &query).average(:age)
          result.must_equal 31
        end
      end
    end

    describe 'avg' do
      let(:user1) { TestUser.new(name: 'L', age: 32) }
      let(:user2) { TestUser.new(name: 'MG', age: 31) }

      describe 'with an empty collection' do
        it 'returns nil' do
          result = @adapter.query(collection) do
            all
          end.avg(:age)

          result.must_be_nil
        end
      end

      describe 'with a filled collection' do
        before do
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
          @adapter.create(collection, TestUser.new(name: 'S'))
        end

        it 'returns the average of all the records' do
          query = proc do
            all
          end

          result = @adapter.query(collection, &query).avg(:age)
          result.must_equal 31.5
        end

        it 'returns the average from an empty query block' do
          query = proc {}

          result = @adapter.query(collection, &query).avg(:age)
          result.must_equal 31.5
        end

        it 'returns only the average of requested records' do
          name = user2.name

          query = proc do
            where(name: name)
          end

          result = @adapter.query(collection, &query).avg(:age)
          result.must_equal 31
        end
      end
    end

    describe 'max' do
      describe 'with an empty collection' do
        it 'returns nil' do
          result = @adapter.query(collection) do
            all
          end.max(:age)

          result.must_be_nil
        end
      end

      describe 'with a filled collection' do
        before do
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
          @adapter.create(collection, TestUser.new(name: 'S'))
        end

        it 'returns the maximum of all the records' do
          query = proc do
            all
          end

          result = @adapter.query(collection, &query).max(:age)
          result.must_equal 32
        end

        it 'returns the maximum from an empty query block' do
          query = proc do
          end

          result = @adapter.query(collection, &query).max(:age)
          result.must_equal 32
        end

        it 'returns only the maximum of requested records' do
          name = user2.name

          query = proc do
            where(name: name)
          end

          result = @adapter.query(collection, &query).max(:age)
          result.must_equal 31
        end
      end
    end

    describe 'min' do
      describe 'with an empty collection' do
        it 'returns nil' do
          result = @adapter.query(collection) do
            all
          end.min(:age)

          result.must_be_nil
        end
      end

      describe 'with a filled collection' do
        before do
          @adapter.create(collection, user1)
          @adapter.create(collection, user2)
          @adapter.create(collection, TestUser.new(name: 'S'))
        end

        it 'returns the minimum of all the records' do
          query = proc do
            all
          end

          result = @adapter.query(collection, &query).min(:age)
          result.must_equal 31
        end

        it 'returns the minimum from an empty query block' do
          query = proc {}

          result = @adapter.query(collection, &query).min(:age)
          result.must_equal 31
        end

        it 'returns only the minimum of requested records' do
          name = user1.name

          query = proc do
            where(name: name)
          end

          result = @adapter.query(collection, &query).min(:age)
          result.must_equal 32
        end
      end
    end
  end
end
