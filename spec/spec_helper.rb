ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + '/../lib/scoped_from'

Dir["#{File.dirname(__FILE__)}/mocks/*.rb"].each { |f| require f }

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => "#{File.dirname(__FILE__)}/test.sqlite3", :timeout => 5000)
User.connection.create_table(:users, :force => true) do |t|
  t.string :firstname
  t.string :lastname
  t.boolean :enabled
end

RSpec.configure do |config|
  config.mock_with(:rspec)
  
  config.before(:each) do
    User.delete_all
    @john = User.create!(:firstname => 'John', :lastname => 'Doe', :enabled => true)
    @jane = User.create!(:firstname => 'Jane', :lastname => 'Doe', :enabled => false)
  end
end