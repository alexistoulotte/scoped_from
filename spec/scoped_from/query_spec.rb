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
  
  describe '#order_column' do
    
    it 'is column specified into "order" parameter' do
      query(User, :order => 'firstname').order_column.should == 'firstname'
      query(User, :order => 'lastname.desc').order_column.should == 'lastname'
    end
    
    it 'is nil if column does not exist' do
      query(User, :order => 'foo').order_column.should be_nil
    end
    
    it 'is nil if "order" param is not specified' do
      query(User, :search => 'foo').order_column.should be_nil
    end
    
  end
  
  describe '#order_direction' do
    
    it 'is direction specified into "order" parameter' do
      query(User, :order => 'firstname.asc').order_direction.should == 'asc'
      query(User, :order => 'firstname.desc').order_direction.should == 'desc'
    end
    
    it 'is "asc" if direction is not specified' do
      query(User, :order => 'firstname').order_direction.should == 'asc'
    end
    
    it 'is "asc" if direction is invalid' do
      query(User, :order => 'firstname.foo').order_direction.should == 'asc'
    end
    
    it 'is direction even specified in another case' do
      query(User, :order => 'firstname.ASc').order_direction.should == 'asc'
      query(User, :order => 'firstname.DeSC').order_direction.should == 'desc'
    end
    
    it 'is nil if column does not exist' do
      query(User, :order => 'foo.desc').order_direction.should be_nil
    end
    
    it 'is nil if "order" param is not specified' do
      query(User, :search => 'foo').order_direction.should be_nil
    end
    
  end
  
  describe '#params=' do
    
    it 'does not fails if nil is given' do
      query(User, nil).params.should == {}
    end
    
    it 'returns correct params' do
      query(User, :search => 'foo', 'enabled' => true).params.should == { 'search' => 'foo', 'enabled' => true }
    end
    
    it 'returns an hash with indifferent access' do
      query(User, 'search' => 'bar').params.should be_a(ActiveSupport::HashWithIndifferentAccess)
      query(User, 'search' => 'bar').params[:search].should == 'bar'
      query(User, :search => 'bar').params['search'].should == 'bar'
    end
    
    it 'removes values that are not scopes' do
      query(User, :foo => 'bar', 'search' => 'foo', :enabled => true).params.should == { 'search' => 'foo', 'enabled' => true }
    end
    
    it 'removes blank values' do
      query(User, 'enabled' => true, 'search' => " \n").params.should == { 'enabled' => true }
    end
    
    it 'is case sensitive' do
      query(User, 'Enabled' => true, "SEARCH" => 'bar').params.should be_empty
    end
    
    it 'parse query string' do
      query(User, 'search=foo%26baz&latest=true').params.should == { 'search' => 'foo&baz', 'latest' => true }
    end
    
    it 'removes blank values from query string' do
      query(User, 'search=baz&toto=&bar=%20').params.should == { 'search' => 'baz' }
    end
    
    it 'can have multiple values (from hash)' do
      query(User, :search => ['bar', 'baz']).params.should == { 'search' => ['bar', 'baz'] }
    end
    
    it 'can have multiple values (from query string)' do
      query(User, 'search=bar&search=baz').params.should == { 'search' => ['bar', 'baz'] }
    end
    
    it 'removes blank values from array' do
      query(User, :search => [nil, 'bar', "\n ", 'baz']).params.should == { 'search' => ['bar', 'baz'] }
    end
    
    it 'converts value to true (or remove it) if scope takes no argument' do
      query(User, :latest => 'y').params.should == { 'latest' => true }
      query(User, :latest => 'no').params.should == {}
    end
    
    it 'converts array value to true (or remove it) if scope takes no argument' do
      query(User, :latest => ['no', 'yes']).params.should == { 'latest' => true }
      query(User, :latest => ['no', nil]).params.should == {}
      query(User, :latest => ['fo']).params.should == {}
    end
    
    it 'flats array' do
      query(User, :search => [nil, ['bar', '', 'foo', ["\n ", 'baz']]]).params.should == { 'search' => ['bar', 'foo', 'baz'] }
    end
    
    it 'change array with a single value in one value' do
      query(User, :search => [nil, 'bar', "\n"]).params.should == { 'search' => 'bar' }
    end
    
    it 'does not modify given hash' do
      hash = { :search => 'foo', :enabled => '1', :bar => 'foo' }
      query(User, hash)
      hash.should == { :search => 'foo', :enabled => '1', :bar => 'foo' }
    end
    
    it 'does not modify given array' do
      items = ['bar', 'foo', nil]
      query(User, :search => items)
      items.should == ['bar', 'foo', nil]
    end
    
    it 'accepts :only option' do
      query(User, { :search => 'bar', :enabled => 'true' }, :only => [:search]).params.should == { 'search' => 'bar' }
      query(User, { :search => 'bar', :enabled => 'true' }, :only => 'search').params.should == { 'search' => 'bar' }
    end
    
    it 'accepts :except option' do
      query(User, { :search => 'bar', :enabled => true }, :except => [:search]).params.should == { 'enabled' => true }
      query(User, { :search => 'bar', :enabled => true }, :except => 'search').params.should == { 'enabled' => true }
    end
    
    it 'accepts a query instance' do
      query(User, query(User, :search => 'toto')).params.should == { 'search' => 'toto' }
    end
    
    it 'preserve blank values if :include_blank option is true' do
      query(User, { :search => "\n ", 'enabled' => true }, :include_blank => true).params.should == { 'search' => "\n ", 'enabled' => true }
    end
    
    it 'preserve blank values from array if :include_blank option is true' do
      query(User, { 'search' => ["\n ", 'toto', 'titi'] }, :include_blank => true).params.should == { 'search' => ["\n ", 'toto', 'titi'] }
      query(User, { 'search' => [] }, :include_blank => true).params.should == {}
    end
    
    it 'also preserve blank on query string if :include_blank option is true' do
      query(User, 'search=%20&enabled=true&search=foo', :include_blank => true).params.should == { 'search' => [' ', 'foo'], 'enabled' => true }
    end
    
    it 'removes column values' do
      query(User, 'firstname' => 'Jane', 'foo' => 'bar').params.should == {}
    end
    
    it 'include column values if :include_columns option is specified' do
      query(User, { 'firstname' => 'Jane', 'foo' => 'bar' }, :include_columns => true).params.should == { 'firstname' => 'Jane' }
      query(User, { :firstname => 'Jane', :foo => 'bar' }, :include_columns => true).params.should == { 'firstname' => 'Jane' }
      query(User, { 'firstname' => ['Jane', 'John'], 'foo' => 'bar' }, :include_columns => true).params.should == { 'firstname' => ['Jane', 'John'] }
      query(User, { 'firstname' => "\n ", 'foo' => 'bar' }, :include_columns => true).params.should == {}
      query(User, { 'firstname' => "\n ", 'foo' => 'bar' }, :include_columns => true, :include_blank => true).params.should == { 'firstname' => "\n " }
    end
    
    it 'maps an "order"' do
      query(User, { 'order' => 'firstname.asc' }).params.should == { 'order' => 'firstname.asc' }
    end
    
    it 'does not map "order" if column is invalid' do
      query(User, { 'order' => 'foo.asc' }).params.should == {}
    end
    
    it 'use "asc" order direction by default' do
      query(User, { 'order' => 'firstname' }).params.should == { 'order' => 'firstname.asc' }
    end
    
    it 'use "asc" order direction if invalid' do
      query(User, { 'order' => 'firstname.bar' }).params.should == { 'order' => 'firstname.asc' }
    end
    
    it 'use "desc" order direction if specified' do
      query(User, { 'order' => 'firstname.desc' }).params.should == { 'order' => 'firstname.desc' }
    end
    
    it 'order direction is case insensitive' do
      query(User, { 'order' => 'firstname.Asc' }).params.should == { 'order' => 'firstname.asc' }
      query(User, { 'order' => 'firstname.DESC' }).params.should == { 'order' => 'firstname.desc' }
    end
    
    it 'order can be specified as symbol' do
      query(User, { :order => 'firstname.desc' }).params.should == { 'order' => 'firstname.desc' }
    end
    
    it "order is case sensitive" do
      query(User, { 'Order' => 'firstname.desc' }).params.should == {}
    end
    
    it 'use last "order" if many are specified' do
      query(User, { 'order' => ['firstname.Asc', 'lastname.DESC'] }).params.should == { 'order' => 'lastname.desc' }
      query(User, { 'order' => ['firstname.Asc', 'lastname.DESC', 'firstname.desc'] }).params.should == { 'order' => 'firstname.desc' }
    end
    
    it 'order can be delimited by a space' do
      query(User, { 'order' => 'firstname ASC' }).params.should == { 'order' => 'firstname.asc' }
    end
    
    it 'order can be delimited by any white space' do
      query(User, { 'order' => "firstname\nASC" }).params.should == { 'order' => 'firstname.asc' }
      query(User, { 'order' => "firstname\t   ASC" }).params.should == { 'order' => 'firstname.asc' }
    end
    
    it 'order can be delimited by a ":"' do
      query(User, { 'order' => "firstname:ASC" }).params.should == { 'order' => 'firstname.asc' }
    end
    
    it 'order can be delimited by more than one delimiter' do
      query(User, { 'order' => "firstname :.  ASC" }).params.should == { 'order' => 'firstname.asc' }
    end
    
  end
  
  describe '#scope' do
    
    it 'does not execute any query' do
      User.should_not_receive(:connection)
      query(User, :enabled => true).scope
    end
    
    it 'works with scopes with a lambda without arguments' do
      users(:jane).update_attribute(:created_at, 10.days.ago)
      query(User, :latest => true).scope.should == [users(:john)]
      query(User, :latest => false).scope.should == [users(:john), users(:jane)]
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
      query(User, :search => ['John', 'Doe']).params.should == { 'search' => ['John', 'Doe'] }
    end
    
    it 'invokes many times scope if given twice (as string & symbol)' do
      query(User, :search => 'John', 'search' => 'Done').params['search'].size.should be(2)
      query(User, :search => 'John', 'search' => 'Done').params['search'].should include('John', 'Done')
      
      
      query(User, :search => 'John', 'search' => ['Did', 'Done']).params['search'].size.should be(3)
      query(User, :search => 'John', 'search' => ['Did', 'Done']).params['search'].should include('John', 'Did', 'Done')
    end
    
    it 'invokes last order if an array is given' do
      query(User, :order => ['lastname', 'firstname']).scope.should == [users(:jane), users(:john)]
      query(User, :order => ['lastname', 'firstname.desc']).scope.should == [users(:john), users(:jane)]
      query(User, :order => ['firstname.desc', 'lastname']).scope.order_values.should == ['lastname ASC']
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
    
    it 'returns given scope if scope takes more than 1 argument' do
      query.send(:scoped, User, :created_between, true).should == User
    end
    
    it 'invokes scope without arguments if scope takes not argument' do
      query.send(:scoped, User.scoped, :enabled, true).should == [users(:john)]
      query.send(:scoped, User.scoped, :enabled, ' 1 ').should == [users(:john)]
      query.send(:scoped, User.scoped, :enabled, 'off').should == [users(:john)]
    end
    
    it 'invokes scope with value has argument if scope takes one argument' do
      query.send(:scoped, User.scoped, :search, 'doe').should == [users(:john), users(:jane)]
      query.send(:scoped, User.scoped, :search, 'john').should == [users(:john)]
      query.send(:scoped, User.scoped, :search, 'jane').should == [users(:jane)]
    end
    
    it 'scope on column conditions' do
      query.send(:scoped, User.scoped, :firstname, 'Jane').should == [users(:jane)]
    end
    
    it 'invokes "order"' do
      query.send(:scoped, User.scoped, :order, 'firstname.asc').should == [users(:jane), users(:john)]
      query.send(:scoped, User.scoped, :order, 'firstname.desc').should == [users(:john), users(:jane)]
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
