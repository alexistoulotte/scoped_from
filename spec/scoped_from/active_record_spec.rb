require 'spec_helper'

describe ScopedFrom::ActiveRecord do
  
  describe '#scope_arity' do
    
    it 'is correct value' do
      User.scope_arity(:enabled).should be(-1)
      User.scope_arity(:search).should be(1)
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
    
  end
  
end
