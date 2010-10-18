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
    
    it 'adds scope specified as parameter' do
      User.scoped_from(:search => 'jane').all.should == [@jane]
    end
    
    it 'accepts string as keys' do
      User.scoped_from('search' => 'jane').all.should == [@jane]
    end
    
    it 'accepts many scopes' do
      User.scoped_from(:search => 'jane', :enabled => true).all.should be_empty
      User.scoped_from(:search => 'john', :enabled => true).all.should == [@john]
    end
    
    it 'does not fails if params is nil' do
      User.scoped_from(nil).should == User.all
    end
    
    it 'returns a new scope' do
      User.scoped_from({}).should be_a(ActiveRecord::Relation)
    end
    
    it 'does not fails if scope does not exists' do
      User.scoped_from(:foo => 'bar').should == User.all
    end
    
  end
  
end
