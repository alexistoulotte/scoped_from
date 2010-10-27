require 'spec_helper'

describe ScopedFrom::Query do
  
  def query(scope = User, params = {}, options = {})
    ScopedFrom::Query.new(scope, params, options)
  end
  
  describe '#initialize' do
    
    it 'invokes #scoped method on specified scope' do
      User.should_receive(:scoped)
      ScopedFrom::Query.new(User, {})
    end
    
  end
  
  describe '#include?' do
    
    it 'is true if query has specified key' do
      query(User, 'foo' => 'bar').include?('foo').should be_true
    end
    
    it 'is false otherwhise' do
      query(User, 'bar' => 'foo').include?('foo').should be_false
    end
    
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
    
    it 'accepts a query instance' do
      query(User, query(User, { :foo => 'toto', 'bar' => 'baz' }, :only => :foo)).params.should == { 'foo' => 'toto' }
    end
    
    it 'preserve blank values if :include_blank option is true' do
      query(User, { :foo => nil, 'toto' => 'titi', 'bar' => "\n " }, :include_blank => true).params.should == { 'foo' => nil, 'toto' => 'titi', 'bar' => "\n " }
    end
    
    it 'preserve blank values from array if :include_blank option is true' do
      query(User, { :foo => nil, 'toto' => 'titi', 'bar' => ["\n ", 'toto', 'titi'] }, :include_blank => true).params.should == { 'foo' => nil, 'toto' => 'titi', 'bar' => ["\n ", 'toto', 'titi'] }
      query(User, { 'toto' => 'titi', 'bar' => [] }, :include_blank => true).params.should == { 'toto' => 'titi' }
    end
    
    it 'also preserve blank on query string if :include_blank option is true' do
      query(User, 'toto=&titi=%20&titi=tata', :include_blank => true).params.should == { 'toto' => '', 'titi' => [' ', 'tata'] }
    end
    
  end
  
  describe '#scope' do
    
    it 'does not execute any query' do
      User.should_not_receive(:connection)
      query(User, :enabled => true).scope
    end
    
    it 'does not modify scope specified at initialization' do
      scope = User.search('foo')
      q = query(scope, :enabled => true)
      expect {
        expect {
          q.scope
        }.to_not change { q.instance_variable_get('@scope') }
      }.to_not change { scope }
    end
    
    it 'returns scope (#scoped) specified at construction if params are empty' do
      query.scope.should_not == User
      query.scope.should == User.scoped
    end
    
    it 'invokes many times scope if an array is given' do
      query(User, :search => ['John', 'Doe']).scope.should == [users(:john)]
      query(User, :search => ['John', 'Done']).scope.should == []
    end
    
    it 'defines #query method on returned scoped' do
      query(User).scope.should respond_to(:query)
    end
    
    it 'does not defines #query method on scope if already defined' do
      class User
        def self.query
          42
        end
      end
      begin
        User.query.should be(42)
        query(User).scope.query.should be(42)
      ensure
        class User
          class << self
            remove_method :query
          end
        end
      end
    end
    
    it 'does not define #query method for future scopes' do
      query(User).scope.query.should be_present
      User.should_not respond_to(:query)
      User.scoped.should_not respond_to(:query)
      User.enabled.should_not respond_to(:query)
    end
    
    it 'defined #query method returns query' do
      q = query(User)
      q.scope.query.should be_a(ScopedFrom::Query)
      q.scope.query.should be(q)
    end
    
  end
  
  describe '#scoped' do
    
    it 'returns given scope if it has no scope with specified name' do
      query.send(:scoped, User, :foo, true).should == User
    end
    
    it 'returns given scope if scope arity is > 1' do
      query.send(:scoped, User, :created_between, true).should == User
    end
    
    it 'invokes scope without arguments if scope arity is -1 and value is true' do
      query.send(:scoped, User.scoped, :enabled, true).should == [users(:john)]
      query.send(:scoped, User.scoped, :enabled, ' 1 ').should == [users(:john)]
      query.send(:scoped, User.scoped, :enabled, 'off').should == [users(:john), users(:jane)]
    end
    
    it 'invokes scope with value has argument if arity is 1' do
      query.send(:scoped, User.scoped, :search, 'doe').should == [users(:john), users(:jane)]
      query.send(:scoped, User.scoped, :search, 'john').should == [users(:john)]
      query.send(:scoped, User.scoped, :search, 'jane').should == [users(:jane)]
    end
    
  end
  
  describe '#true?' do
    
    it 'is true if true is given' do
      query.send(:true?, true).should be_true
    end
    
    it 'is true if "true" is given' do
      query.send(:true?, 'true').should be_true
      query.send(:true?, 'True').should be_true
    end
    
    it 'is true if "1" is given' do
      query.send(:true?, '1').should be_true
    end
    
    it 'is true if "on" is given' do
      query.send(:true?, 'on').should be_true
      query.send(:true?, 'ON ').should be_true
    end
    
    it 'is true if "yes" is given' do
      query.send(:true?, 'yes').should be_true
      query.send(:true?, ' Yes ').should be_true
    end
    
    it 'is true if "y" is given' do
      query.send(:true?, 'y').should be_true
      query.send(:true?, 'Y ').should be_true
    end
    
    it 'is false if false is given' do
      query.send(:true?, false).should be_false
    end
    
    it 'is false if "false" is given' do
      query.send(:true?, 'false').should be_false
      query.send(:true?, 'FsALSE').should be_false
    end
    
    it 'is false if "0" is given' do
      query.send(:true?, '0').should be_false
    end
    
    it 'is false if "off" is given' do
      query.send(:true?, "off").should be_false
      query.send(:true?, "Off").should be_false
    end
    
    it 'is false otherwise' do
      query.send(:true?, 42).should be_false
      query.send(:true?, 'bam').should be_false
    end
    
  end
  
end
