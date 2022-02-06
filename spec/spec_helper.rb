ENV['RAILS_ENV'] ||= 'test'

require File.expand_path("#{__dir__}/../lib/scoped_from")
require 'action_controller'
require 'byebug'

# Support
Dir["#{__dir__}/support/**/*.rb"].each { |f| require File.expand_path(f) }

# Mocks
Dir["#{__dir__}/mocks/**/*.rb"].each { |f| require File.expand_path(f) }

RSpec.configure do |config|
  config.raise_errors_for_deprecations!

  config.include(UserMacro)

  config.before(:each) do
    Comment.delete_all
    Post.delete_all
    User.delete_all
    Vote.delete_all

    create_user(:john, firstname: 'John', lastname: 'Doe', enabled: true, admin: true)
    create_user(:jane, firstname: 'Jane', lastname: 'Doe', enabled: false, admin: false)
  end
end
