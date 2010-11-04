require 'spec_helper'

describe ScopedFrom::ActiveRecord do
  
  describe '#scope_arity' do
    
    it 'is correct value' do
      User.scope_arity(:enabled).should be(-1)
      User.scope_arity(:search).should be(1)
      User.scope_arity(:created_between).should be(2)
    end
    
    it 'is nil if specified name is undefined' do
      User.scope_arity(:foo).should be_nil
    end
    
    it 'is with indifferent access' do
      User.scope_arity('search').should be(1)
      User.scope_arity(:search).should be(1)
    end
    
  end
  
  describe '#scoped_from' do
    
    it 'just build a new query and return its scope' do
      query = mock(:query)
      query.should_receive(:scope).and_return(42)
      ScopedFrom::Query.should_receive(:new).with(User, 'foo', :except => 'bam').and_return(query)
      User.scoped_from('foo', :except => 'bam').should == 42
    end
    
    it 'build scopes' do
      User.scoped_from(:search => 'jane').should == [users(:jane)]
      User.scoped_from(:search => 'john').should == [users(:john)]
    end
    
    it 'can be chained with other scopes' do
      User.scoped_from(:search => 'jane').should == [users(:jane)]
      User.enabled.scoped_from(:search => 'jane').should == []
    end
    
    it 'builds a ScopedFrom::Query' do
      User.scoped_from({}).query.class.should be(ScopedFrom::Query)
    end
    
    it 'builds a ScopedFrom::Query if #{RecordClassName}Query is not defined' do
      Post.scoped_from({}).query.class.should be(ScopedFrom::Query)
      Object.const_defined?('PostQuery').should be_false
      expect {
        PostQuery
      }.to raise_error(NameError, 'uninitialized constant PostQuery')
    end
    
    it 'builds a #{Class}Query if #{RecordClassName}Query is defined and is a ScopedFrom::Query' do
      Comment.scoped_from({}).query.class.should be(CommentQuery)
      Comment.where(:foo => 'bar').scoped_from({}).query.class.should be(CommentQuery)
      CommentQuery.should be_a(Class)
      CommentQuery.ancestors.should include(ScopedFrom::Query)
    end
    
    it 'builds a ScopedFrom::Query if #{RecordClassName}Query is defined but not a subclass of ScopedFrom::Query' do
      User.scoped_from({}).query.class.should be(ScopedFrom::Query)
      Object.const_defined?('UserQuery').should be_true
      UserQuery.should be_a(Class)
      UserQuery.ancestors.should_not include(ScopedFrom::Query)
    end
    
    it 'builds a ScopedFrom::Query if #{RecordClassName}Query is defined but is a module' do
      Vote.scoped_from({}).query.class.should be(ScopedFrom::Query)
      Object.const_defined?('VoteQuery').should be_true
      VoteQuery.should be_a(Module)
    end
    
  end
  
end
