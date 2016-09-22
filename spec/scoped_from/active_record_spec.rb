require 'spec_helper'

describe ScopedFrom::ActiveRecord do

  describe '#scope_with_one_argument?' do

    it 'is true if scope has one argument' do
      expect(User.scope_with_one_argument?(:search)).to be(true)
      expect(User.scope_with_one_argument?('search')).to be(true)
    end

    it 'is false if scope has no argument' do
      expect(User.scope_with_one_argument?(:latest)).to be(false)
      expect(User.scope_with_one_argument?('latest')).to be(false)
    end

    it 'is false if scope has more than one argument' do
      expect(User.scope_with_one_argument?(:created_between)).to be(false)
      expect(User.scope_with_one_argument?('created_between')).to be(false)
    end

    it 'is false if scope is not a proc' do
      expect(User.scope_with_one_argument?(:enabled)).to be(false)
      expect(User.scope_with_one_argument?('enabled')).to be(false)
    end

    it 'is false if scope does not exist' do
      expect(User.scope_with_one_argument?(:foo)).to be(false)
      expect(User.scope_with_one_argument?('foo')).to be(false)
    end

  end

  describe 'scope_without_argument?' do

    it 'is true if scope has no argument' do
      expect(User.scope_without_argument?(:latest)).to be(true)
      expect(User.scope_without_argument?('latest')).to be(true)
    end

    it 'is true if scope is not a proc' do
      expect(User.scope_without_argument?(:enabled)).to be(true)
      expect(User.scope_without_argument?('enabled')).to be(true)
    end

    it 'is false if scope has one argument' do
      expect(User.scope_without_argument?(:search)).to be(false)
      expect(User.scope_without_argument?('search')).to be(false)
    end

    it 'is false if scope has more than one argument' do
      expect(User.scope_without_argument?(:created_between)).to be(false)
      expect(User.scope_without_argument?('created_between')).to be(false)
    end

    it 'is false if scope does not exist' do
      expect(User.scope_without_argument?(:foo)).to be(false)
      expect(User.scope_without_argument?('foo')).to be(false)
    end

  end

  describe '#scoped_from' do

    it 'just build a new query and return its scope' do
      query = double(:query)
      expect(query).to receive(:relation).and_return(42)
      expect(ScopedFrom::Query).to receive(:new).with(User, 'foo', except: 'bam').and_return(query)
      expect(User.scoped_from('foo', except: 'bam')).to eq(42)
    end

    it 'build scopes' do
      expect(User.scoped_from(search: 'jane')).to eq([users(:jane)])
      expect(User.scoped_from(search: 'john')).to eq([users(:john)])
    end

    it 'can be chained with other scopes' do
      expect(User.scoped_from(search: 'jane')).to eq([users(:jane)])
      expect(User.enabled.scoped_from(search: 'jane')).to eq([])
    end

    it 'can be used with order as parameter' do
      expect(User.scoped_from(order: 'firstname').first).to eq(users(:jane))
      expect(User.scoped_from(order: 'firstname.desc').first).to eq(users(:john))
    end

    it 'builds a ScopedFrom::Query' do
      expect(User.scoped_from({}).query.class).to be(ScopedFrom::Query)
    end

    it 'builds a ScopedFrom::Query if #{RecordClassName}Query is not defined' do
      expect(Post.scoped_from({}).query.class).to be(ScopedFrom::Query)
      expect(Object.const_defined?('PostQuery')).to be(false)
      expect {
        PostQuery
      }.to raise_error(NameError, 'uninitialized constant PostQuery')
    end

    it 'builds a #{Class}Query if #{RecordClassName}Query is defined and is a ScopedFrom::Query' do
      expect(Comment.scoped_from({}).query.class).to be(CommentQuery)
      expect(Comment.where(foo: 'bar').scoped_from({}).query.class).to be(CommentQuery)
      expect(CommentQuery).to be_a(Class)
      expect(CommentQuery.ancestors).to include(ScopedFrom::Query)
    end

    it 'builds a ScopedFrom::Query if #{RecordClassName}Query is defined but not a subclass of ScopedFrom::Query' do
      expect(User.scoped_from({}).query.class).to be(ScopedFrom::Query)
      expect(Object.const_defined?('UserQuery')).to be(true)
      expect(UserQuery).to be_a(Class)
      expect(UserQuery.ancestors).not_to include(ScopedFrom::Query)
    end

    it 'builds a ScopedFrom::Query if #{RecordClassName}Query is defined but is a module' do
      expect(Vote.scoped_from({}).query.class).to be(ScopedFrom::Query)
      expect(Object.const_defined?('VoteQuery')).to be(true)
      expect(VoteQuery).to be_a(Module)
    end

    it 'is accepts ActionController::Parameters' do
      expect(User.scoped_from(ActionController::Parameters.new(search: 'jane'))).to eq([users(:jane)])
    end

  end

end
