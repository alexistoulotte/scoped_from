ENV["RAILS_ENV"] ||= 'test'

require File.dirname(__FILE__) + '/../lib/scoped_from'

# Support 
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Mocks
ActiveSupport::Dependencies.autoload_paths << "#{File.dirname(__FILE__)}/mocks"

RSpec.configure do |config|
  config.include(UserMacro)
  
  config.before(:each) do
    Comment.delete_all
    Post.delete_all
    User.delete_all
    Vote.delete_all
    
    create_user(:john, :firstname => 'John', :lastname => 'Doe', :enabled => true, :admin => true)
    create_user(:jane, :firstname => 'Jane', :lastname => 'Doe', :enabled => false, :admin => false)
  end
end