require 'spec_helper'

describe ScopedFrom::ActiveRecord do

  describe '#scope_with_one_argument?' do

    it 'is true if scope has one argument' do
      User.should be_scope_with_one_argument(:search)
      User.should be_scope_with_one_argument('search')
    end
    
    it 'is false if scope has no argument' do
      User.should_not be_scope_with_one_argument(:latest)
      User.should_not be_scope_with_one_argument('latest')
    end
    
    it 'is false if scope has more than one argument' do
      User.should_not be_scope_with_one_argument(:created_between)
      User.should_not be_scope_with_one_argument('created_between')
    end
    
    it 'is false if scope is not a proc' do
      User.should_not be_scope_with_one_argument(:enabled)
      User.should_not be_scope_with_one_argument('enabled')
    end
    
    it 'is false if scope does not exist' do
      User.should_not be_scope_with_one_argument(:foo)
      User.should_not be_scope_with_one_argument('foo')
    end
    
  end
  
  describe 'scope_without_argument?' do
    
    it 'is true if scope has no argument' do
      User.should be_scope_without_argument(:latest)
      User.should be_scope_without_argument('latest')
    end
    
    it 'is true if scope is not a proc' do
      User.should be_scope_without_argument(:enabled)
      User.should be_scope_without_argument('enabled')
    end
    
    it 'is false if scope has one argument' do
      User.should_not be_scope_without_argument(:search)
      User.should_not be_scope_without_argument('search')
    end
    
    it 'is false if scope has more than one argument' do
      User.should_not be_scope_without_argument(:created_between)
      User.should_not be_scope_without_argument('created_between')
    end
    
    it 'is false if scope does not exist' do
      User.should_not be_scope_without_argument(:foo)
      User.should_not be_scope_without_argument('foo')
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
    
    it 'can be used with order as parameter' do
      User.scoped_from(:order => 'firstname').first.should == users(:jane)
      User.scoped_from(:order => 'firstname.desc').first.should == users(:john)
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
