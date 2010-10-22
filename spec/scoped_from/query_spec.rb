require 'spec_helper'

describe ScopedFrom::Query do
  
  def query(scope, params, options = {})
    ScopedFrom::Query.new(scope, params, options)
  end
  
  describe '#params=' do
    
    it 'does not fails if nil is given' do
      query(User, nil).params.should == {}
    end
    
    it 'returns correct params' do
      query(User, :foo => 'bar', 'toto' => 42).params.should == { 'foo' => 'bar', 'toto' => 42 }
    end
    
    it 'returns an hash with indifferent access' do
      query(User, 'foo' => 'bar').params.should be_a(ActiveSupport::HashWithIndifferentAccess)
      query(User, 'foo' => 'bar').params[:foo].should == 'bar'
      query(User, :foo => 'bar').params['foo'].should == 'bar'
    end
    
    it 'removes blank values' do
      query(User, 'foo' => 'bar', 'baz' => " \n").params.should == { 'foo' => 'bar' }
    end
    
    it 'parse query string' do
      query(User, 'bar=foo%26baz&toto=titi').params.should == { 'bar' => 'foo&baz', 'toto' => 'titi' }
    end
    
    it 'removes blank values from query string' do
      query(User, 'bar=baz&toto=&bar=%20').params.should == { 'bar' => 'baz' }
    end
    
    it 'can have multiple values (from hash)' do
      query(User, :foo => ['bar', 'baz']).params.should == { 'foo' => ['bar', 'baz'] }
    end
    
    it 'can have multiple values (from query string)' do
      query(User, 'foo=bar&foo=baz').params.should == { 'foo' => ['bar', 'baz'] }
    end
    
    it 'removes blank values from array' do
      query(User, :foo => [nil, 'bar', "\n ", 'baz']).params.should == { 'foo' => ['bar', 'baz'] }
    end
    
    it 'flats array' do
      query(User, :foo => [nil, ['bar', '', 'foo', ["\n ", 'baz']]]).params.should == { 'foo' => ['bar', 'foo', 'baz'] }
    end
    
    it 'change array with a single value in one value' do
      query(User, :foo => [nil, 'bar', "\n"]).params.should == { 'foo' => 'bar' }
    end
    
    it 'does not modify given array' do
      items = ['bar', 'foo', nil]
      query(User, :baz => items)
      items.should == ['bar', 'foo', nil]
    end
    
    it 'accepts :only option' do
      query(User, { :foo => 'bar', :baz => 'toto', :bar => 'baz' }, :only => [:foo, 'bar']).params.should == { 'foo' => 'bar', 'bar' => 'baz' }
      query(User, { :foo => 'bar', :baz => 'toto', :bar => 'baz' }, :only => :foo).params.should == { 'foo' => 'bar' }
    end
    
    it 'accepts :except option' do
      query(User, { :foo => 'bar', :baz => 'toto', :bar => 'baz' }, :except => [:foo, 'bar']).params.should == { 'baz' => 'toto' }
      query(User, { :foo => 'bar', :baz => 'toto', :bar => 'baz' }, :except => :foo).params.should == { 'baz' => 'toto', 'bar' => 'baz' }
    end
    
  end
  
end
