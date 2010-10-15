ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + '/../lib/scoped_from'

RSpec.configure do |config|
  config.mock_with :rspec
end