ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + '/../lib/scoped_from'

# Support 
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Mocks
Dir["#{File.dirname(__FILE__)}/mocks/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with(:rspec)
  
  config.include(UserMacro)
  
  config.before(:each) do
    User.delete_all
    create_user(:john, :firstname => 'John', :lastname => 'Doe', :enabled => true)
    create_user(:jane, :firstname => 'Jane', :lastname => 'Doe', :enabled => false)
  end
end