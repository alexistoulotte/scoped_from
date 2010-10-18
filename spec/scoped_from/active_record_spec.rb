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
    
    it 'should have specs'
    
  end
  
end
