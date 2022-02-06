require 'spec_helper'

describe ScopedFrom::Query do

  def query(relation = User, params = {}, options = {})
    ScopedFrom::Query.new(relation, params, options)
  end

  describe '#false?' do

    it 'is true if false is given' do
      expect(query.send(:false?, false)).to be(true)
    end

    it 'is true if "false" is given' do
      expect(query.send(:false?, 'false')).to be(true)
      expect(query.send(:false?, 'False')).to be(true)
    end

    it 'is true if "0" is given' do
      expect(query.send(:false?, '0')).to be(true)
    end

    it 'is true if "off" is given' do
      expect(query.send(:false?, 'off')).to be(true)
      expect(query.send(:false?, 'OFF ')).to be(true)
    end

    it 'is true if "no" is given' do
      expect(query.send(:false?, 'no')).to be(true)
      expect(query.send(:false?, ' No ')).to be(true)
    end

    it 'is true if "n" is given' do
      expect(query.send(:false?, 'n')).to be(true)
      expect(query.send(:false?, 'N ')).to be(true)
    end

    it 'is false if true is given' do
      expect(query.send(:false?, true)).to be(false)
    end

    it 'is false if "true" is given' do
      expect(query.send(:false?, 'true')).to be(false)
      expect(query.send(:false?, 'TrUe')).to be(false)
    end

    it 'is false if "1" is given' do
      expect(query.send(:false?, '1')).to be(false)
    end

    it 'is false if "on" is given' do
      expect(query.send(:false?, 'on')).to be(false)
      expect(query.send(:false?, 'On')).to be(false)
    end

    it 'is false otherwise' do
      expect(query.send(:false?, 42)).to be(false)
      expect(query.send(:false?, 'bam')).to be(false)
    end

  end

  describe '#initialize' do

    it 'invokes .all method on given class' do
      expect(User).to receive(:all)
      ScopedFrom::Query.new(User, {})
    end

    it 'does not invokes .all method on given relation' do
      relation = User.all
      expect(relation).not_to receive(:all)
      ScopedFrom::Query.new(relation, {})
    end

  end

  describe '#invoke_param' do

    it 'returns given scope if it has no scope with specified name' do
      expect(query.send(:invoke_param, User, :foo, true)).to eq(User)
    end

    it 'returns given scope if scope takes more than 1 argument' do
      expect(query.send(:invoke_param, User, :created_between, true)).to eq(User)
    end

    it 'invokes scope without arguments if scope takes no arguments' do
      expect(query.send(:invoke_param, User.all, :enabled, true)).to eq([users(:john)])
      expect(query.send(:invoke_param, User.all, :enabled, ' 1 ')).to eq([users(:john)])
      expect(query.send(:invoke_param, User.all, :enabled, 'off')).to eq([users(:john)])
    end

    it 'invokes scope with value has argument if scope takes one argument' do
      expect(query.send(:invoke_param, User.all, :search, 'doe')).to eq([users(:john), users(:jane)])
      expect(query.send(:invoke_param, User.all, :search, 'john')).to eq([users(:john)])
      expect(query.send(:invoke_param, User.all, :search, 'jane')).to eq([users(:jane)])
    end

    it 'scope on column conditions' do
      expect(query.send(:invoke_param, User.all, :firstname, 'Jane')).to eq([users(:jane)])
    end

    it 'invokes "order"' do
      expect(query.send(:invoke_param, User.all, :order, 'firstname.asc')).to eq([users(:jane), users(:john)])
      expect(query.send(:invoke_param, User.all, :order, 'firstname.desc')).to eq([users(:john), users(:jane)])
    end

  end

  describe '#options' do

    it 'is set at initialization' do
      expect(ScopedFrom::Query.new(User, {}, bar: 'foo').instance_variable_get(:@options)).to eq(bar: 'foo')
    end

    it 'keys are symbolized' do
      expect(ScopedFrom::Query.new(User, {}, 'bar' => 'foo').instance_variable_get(:@options)).to eq(bar: 'foo')
    end

  end

  describe '#order_column' do

    it 'is column specified into "order" parameter' do
      expect(query(User, order: 'firstname').order_column).to eq('firstname')
      expect(query(User, order: 'lastname.desc').order_column).to eq('lastname')
    end

    it 'is nil if column does not exist' do
      expect(query(User, order: 'foo').order_column).to be_nil
    end

    it 'is nil if "order" param is not specified' do
      expect(query(User, search: 'foo').order_column).to be_nil
    end

  end

  describe '#order_direction' do

    it 'is direction specified into "order" parameter' do
      expect(query(User, order: 'firstname.asc').order_direction).to eq('asc')
      expect(query(User, order: 'firstname.desc').order_direction).to eq('desc')
    end

    it 'is "asc" if direction is not specified' do
      expect(query(User, order: 'firstname').order_direction).to eq('asc')
    end

    it 'is "asc" if direction is invalid' do
      expect(query(User, order: 'firstname.foo').order_direction).to eq('asc')
    end

    it 'is direction even specified in another case' do
      expect(query(User, order: 'firstname.ASc').order_direction).to eq('asc')
      expect(query(User, order: 'firstname.DeSC').order_direction).to eq('desc')
    end

    it 'is nil if column does not exist' do
      expect(query(User, order: 'foo.desc').order_direction).to be_nil
    end

    it 'is nil if "order" param is not specified' do
      expect(query(User, search: 'foo').order_direction).to be_nil
    end

  end

  describe '#params' do

    it 'returns params specified at initialization' do
      expect(query(User, search: 'foo', 'enabled' => true).params).to eq({ 'search' => 'foo', 'enabled' => true })
    end

    it 'returns an hash with indifferent access' do
      expect(query(User, 'search' => 'bar').params).to be_a(ActiveSupport::HashWithIndifferentAccess)
      expect(query(User, 'search' => 'bar').params[:search]).to eq('bar')
      expect(query(User, search: 'bar').params['search']).to eq('bar')
    end

    it 'can be converted to query string' do
      expect(query(User, search: %w(foo bar), 'enabled' => '1').params.to_query).to eq('enabled=true&search%5B%5D=foo&search%5B%5D=bar')
    end

  end

  describe '#params=' do

    it 'does not fails if nil is given' do
      expect(query(User, nil).params).to eq({})
    end

    it 'removes values that are not scopes' do
      expect(query(User, foo: 'bar', 'search' => 'foo', enabled: true).params).to eq({ 'search' => 'foo', 'enabled' => true })
    end

    it 'is case sensitive' do
      expect(query(User, 'Enabled' => true, 'SEARCH' => 'bar').params).to be_empty
    end

    it 'parse query string' do
      expect(query(User, 'search=foo%26baz&latest=true').params).to eq({ 'search' => 'foo&baz', 'latest' => true })
    end

    it 'removes blank values from query string' do
      expect(query(User, 'search=baz&toto=&bar=%20').params).to eq({ 'search' => 'baz' })
    end

    it 'unescapes UTF-8 chars' do
      expect(query(User, 'search=%C3%A9').params).to eq({ 'search' => 'é' })
    end

    it 'can have multiple values (from hash)' do
      expect(query(User, search: %w(bar baz)).params).to eq({ 'search' => %w(bar baz) })
    end

    it 'can have multiple values (from query string)' do
      expect(query(User, 'search=bar&search=baz').params).to eq({ 'search' => %w(bar baz) })
    end

    it 'converts value to true (or remove it) if scope takes no argument' do
      expect(query(User, latest: 'y').params).to eq({ 'latest' => true })
      expect(query(User, latest: 'no').params).to eq({})
    end

    it 'converts value to true (or false) if column is a boolean one' do
      expect(query(User, admin: 'y').params).to eq({ 'admin' => true })
      expect(query(User, admin: 'False').params).to eq({ 'admin' => false })
      expect(query(User, admin: 'bar').params).to eq({})
      expect(query(User, admin: ['y', false]).params).to eq({})
    end

    it 'converts array value to true (or remove it) if scope takes no argument' do
      expect(query(User, latest: true).params).to eq({ 'latest' => true })
      expect(query(User, latest: ['Yes']).params).to eq({ 'latest' => true })
      expect(query(User, latest: %w(no yes)).params).to eq({})
      expect(query(User, latest: ['no', nil]).params).to eq({})
      expect(query(User, latest: ['fo']).params).to eq({})
    end

    it 'flats array' do
      expect(query(User, search: [nil, ['bar', '', 'foo', ["\n ", 'baz']]]).params).to eq({ 'search' => [nil, 'bar', '', 'foo', "\n ", 'baz'] })
    end

    it 'change array with a single value in one value' do
      expect(query(User, search: ['bar']).params).to eq({ 'search' => 'bar' })
    end

    it 'does not modify given hash' do
      hash = { search: 'foo', enabled: '1', bar: 'foo' }
      query(User, hash)
      expect(hash).to eq({ search: 'foo', enabled: '1', bar: 'foo' })
    end

    it 'does not modify given array' do
      items = ['bar', 'foo', nil]
      query(User, search: items)
      expect(items).to eq(['bar', 'foo', nil])
    end

    it 'accepts :only option' do
      expect(query(User, { search: 'bar', enabled: 'true' }, only: [:search]).params).to eq({ 'search' => 'bar' })
      expect(query(User, { search: 'bar', enabled: 'true' }, only: 'search').params).to eq({ 'search' => 'bar' })
      expect(query(User, { search: 'bar', firstname: 'Jane', enabled: 'true' }, only: 'search').params).to eq({ 'search' => 'bar' })
      expect(query(User, { search: 'bar', firstname: 'Jane', enabled: 'true' }, only: ['search', :firstname]).params).to eq({ 'search' => 'bar', 'firstname' => 'Jane' })
    end

    it 'accepts :except option' do
      expect(query(User, { search: 'bar', enabled: true }, except: [:search]).params).to eq({ 'enabled' => true })
      expect(query(User, { search: 'bar', enabled: true }, except: 'search').params).to eq({ 'enabled' => true })
      expect(query(User, { search: 'bar', firstname: 'Jane', enabled: true }, except: 'search').params).to eq({ 'enabled' => true, 'firstname' => 'Jane' })
      expect(query(User, { search: 'bar', firstname: 'Jane', enabled: true }, except: ['search', :firstname]).params).to eq({ 'enabled' => true })
    end

    it 'accepts a query instance' do
      expect(query(User, query(User, search: 'toto')).params).to eq({ 'search' => 'toto' })
    end

    it 'preserve blank values' do
      expect(query(User, { search: "\n ", 'enabled' => true }).params).to eq({ 'search' => "\n ", 'enabled' => true })
    end

    it 'preserve blank values from array' do
      expect(query(User, { 'search' => ["\n ", 'toto', 'titi'] }).params).to eq({ 'search' => ["\n ", 'toto', 'titi'] })
      expect(query(User, { 'search' => [] }).params).to eq({})
    end

    it 'also preserve blank on query string' do
      expect(query(User, 'search=%20&enabled=true&search=foo').params).to eq({ 'search' => [' ', 'foo'], 'enabled' => true })
    end

    it 'includes column values' do
      expect(query(User, 'firstname' => 'Jane', 'foo' => 'bar').params).to eq({ 'firstname' => 'Jane' })
      expect(query(User, firstname: 'Jane', 'foo' => 'bar').params).to eq({ 'firstname' => 'Jane' })
    end

    it 'exclude column values if :exclude_columns option is specified' do
      expect(query(User, { enabled: true, 'firstname' => 'Jane', 'foo' => 'bar' }, exclude_columns: true).params).to eq({ 'enabled' => true })
      expect(query(User, { enabled: true, firstname: 'Jane', foo: 'bar' }, exclude_columns: true).params).to eq({ 'enabled' => true })
    end

    it 'scopes have priority on columns' do
      expect(query(User, enabled: false).params).to eq({})
    end

    it 'maps an "order"' do
      expect(query(User, { 'order' => 'firstname.asc' }).params).to eq({ 'order' => 'firstname.asc' })
    end

    it 'does not map "order" if column is invalid' do
      expect(query(User, { 'order' => 'foo.asc' }).params).to eq({})
    end

    it 'use "asc" order direction by default' do
      expect(query(User, { 'order' => 'firstname' }).params).to eq({ 'order' => 'firstname.asc' })
    end

    it 'use "asc" order direction if invalid' do
      expect(query(User, { 'order' => 'firstname.bar' }).params).to eq({ 'order' => 'firstname.asc' })
    end

    it 'use "desc" order direction if specified' do
      expect(query(User, { 'order' => 'firstname.desc' }).params).to eq({ 'order' => 'firstname.desc' })
    end

    it 'order direction is case insensitive' do
      expect(query(User, { 'order' => 'firstname.Asc' }).params).to eq({ 'order' => 'firstname.asc' })
      expect(query(User, { 'order' => 'firstname.DESC' }).params).to eq({ 'order' => 'firstname.desc' })
    end

    it 'order can be specified as symbol' do
      expect(query(User, { order: 'firstname.desc' }).params).to eq({ 'order' => 'firstname.desc' })
    end

    it 'order is case sensitive' do
      expect(query(User, { 'Order' => 'firstname.desc' }).params).to eq({})
    end

    it 'many order can be specified' do
      expect(query(User, { 'order' => ['firstname.Asc', 'lastname.DESC'] }).params).to eq({ 'order' => ['firstname.asc', 'lastname.desc'] })
      expect(query(User, { 'order' => ['firstname.Asc', 'firstname.desc'] }).params).to eq({ 'order' => 'firstname.asc' })
      expect(query(User, { 'order' => ['firstname.Asc', 'lastname.DESC', 'firstname.desc'] }).params).to eq({ 'order' => ['firstname.asc', 'lastname.desc'] })
      expect(query(User, { 'order' => ['firstname.Asc', 'foo', 'lastname.DESC', 'firstname.desc'] }).params).to eq({ 'order' => ['firstname.asc', 'lastname.desc'] })
    end

    it 'order can be delimited by a space' do
      expect(query(User, { 'order' => 'firstname ASC' }).params).to eq({ 'order' => 'firstname.asc' })
    end

    it 'order can be delimited by any white space' do
      expect(query(User, { 'order' => "firstname\nASC" }).params).to eq({ 'order' => 'firstname.asc' })
      expect(query(User, { 'order' => "firstname\t   ASC" }).params).to eq({ 'order' => 'firstname.asc' })
    end

    it 'order can be delimited by a ":"' do
      expect(query(User, { 'order' => 'firstname:ASC' }).params).to eq({ 'order' => 'firstname.asc' })
    end

    it 'order can be delimited by more than one delimiter' do
      expect(query(User, { 'order' => 'firstname :.  ASC' }).params).to eq({ 'order' => 'firstname.asc' })
    end

  end

  describe '#relation' do

    it 'does not execute any query' do
      expect(User).not_to receive(:connection)
      query(User, enabled: true).relation
    end

    it 'works with scopes with a lambda without arguments' do
      users(:jane).update_attribute(:created_at, 10.days.ago)
      expect(query(User, latest: true).relation).to eq([users(:john)])
      expect(query(User, latest: false).relation).to eq([users(:john), users(:jane)])
    end

    it 'does not modify relation specified at initialization' do
      relation = User.search('foo')
      q = query(relation, enabled: true)
      expect {
        expect {
          q.relation
        }.not_to change { q.instance_variable_get('@relation') }
      }.not_to change { relation }
    end

    it 'returns relation specified at construction if params are empty' do
      expect(query.relation).not_to eq(User)
      expect(query.relation).to eq(User.all)
    end

    it 'invokes many times relation if an array is given' do
      expect(query(User, search: %w(John Doe)).relation).to eq([users(:john)])
      expect(query(User, search: %w(John Done)).relation).to eq([])
      expect(query(User, search: %w(John Doe)).params).to eq({ 'search' => %w(John Doe) })
    end

    it 'invokes many times relation if given twice (as string & symbol)' do
      expect(query(User, search: 'John', 'search' => 'Done').params['search']).to contain_exactly('John', 'Done')
      expect(query(User, search: 'John', 'search' => %w(Did Done)).params['search']).to contain_exactly('John', 'Did', 'Done')
    end

    it 'invokes last order if an array is given' do
      create_user(:jane2, firstname: 'Jane', lastname: 'Zoe')

      expect(query(User, order: %w(lastname firstname)).relation).to eq([users(:jane), users(:john), users(:jane2)])
      expect(query(User, order: ['lastname', 'firstname.desc']).relation).to eq([users(:john), users(:jane), users(:jane2)])
      expect(query(User, order: ['firstname', 'lastname.desc']).relation).to eq([users(:jane2), users(:jane), users(:john)])
      expect(query(User, order: ['firstname.desc', 'lastname']).relation.order_values.map(&:class)).to eq([Arel::Nodes::Descending, Arel::Nodes::Ascending])
      expect(query(User, order: ['firstname.desc', 'lastname']).relation.order_values.map(&:expr).map(&:name)).to eq(%w(firstname lastname))
    end

    it 'defines #query method on returned relation' do
      expect(query(User).relation).to respond_to(:query)
    end

    it 'does not define #query method for future relations' do
      expect(query(User).relation.query).to be_present
      expect(User).not_to respond_to(:query)
      expect(User.all).not_to respond_to(:query)
      expect(User.enabled).not_to respond_to(:query)
    end

    it 'defined #query method returns query' do
      q = query(User)
      expect(q.relation.query).to be_a(ScopedFrom::Query)
      expect(q.relation.query).to be(q)
    end

  end

  describe '#true?' do

    it 'is true if true is given' do
      expect(query.send(:true?, true)).to be(true)
    end

    it 'is true if "true" is given' do
      expect(query.send(:true?, 'true')).to be(true)
      expect(query.send(:true?, 'True')).to be(true)
    end

    it 'is true if "1" is given' do
      expect(query.send(:true?, '1')).to be(true)
    end

    it 'is true if "on" is given' do
      expect(query.send(:true?, 'on')).to be(true)
      expect(query.send(:true?, 'ON ')).to be(true)
    end

    it 'is true if "yes" is given' do
      expect(query.send(:true?, 'yes')).to be(true)
      expect(query.send(:true?, ' Yes ')).to be(true)
    end

    it 'is true if "y" is given' do
      expect(query.send(:true?, 'y')).to be(true)
      expect(query.send(:true?, 'Y ')).to be(true)
    end

    it 'is false if false is given' do
      expect(query.send(:true?, false)).to be(false)
    end

    it 'is false if "false" is given' do
      expect(query.send(:true?, 'false')).to be(false)
      expect(query.send(:true?, 'FsALSE')).to be(false)
    end

    it 'is false if "0" is given' do
      expect(query.send(:true?, '0')).to be(false)
    end

    it 'is false if "off" is given' do
      expect(query.send(:true?, 'off')).to be(false)
      expect(query.send(:true?, 'Off')).to be(false)
    end

    it 'is false otherwise' do
      expect(query.send(:true?, 42)).to be(false)
      expect(query.send(:true?, 'bam')).to be(false)
    end

  end

end
