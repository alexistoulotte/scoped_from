Gem::Specification.new do |s|
  s.name = 'scoped_from'
  s.version = File.read("#{File.dirname(__FILE__)}/VERSION").strip
  s.platform = Gem::Platform::RUBY
  s.author = 'Alexis Toulotte'
  s.email = 'al@alweb.org'
  s.homepage = 'https://github.com/alexistoulotte/scoped_from'
  s.summary = 'Mapping between scopes and parameters for Rails'
  s.description = 'Provides a simple mapping between Active Record scopes and controller parameters for Ruby On Rails 4'
  s.license = 'MIT'

  s.files = %x(git ls-files | grep -vE '^(spec/|test/|\\.|Gemfile|Rakefile)').split("\n")
  s.executables = %x(git ls-files -- bin/*).split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 3.1.0'

  s.add_dependency 'activerecord', '>= 7.0.0', '< 8.0.0'
  s.add_dependency 'activesupport', '>= 7.0.0', '< 8.0.0'

  s.add_development_dependency 'actionpack', '>= 7.0.0', '< 8.0.0'
  s.add_development_dependency 'byebug', '>= 3.2.0', '< 12.0.0'
  s.add_development_dependency 'rake', '>= 10.3.0', '< 14.0.0'
  s.add_development_dependency 'rspec', '>= 3.1.0', '< 3.11.0'
  s.add_development_dependency 'rubocop', '>= 1.25.0', '< 2.0.0'
  s.add_development_dependency 'rubocop-rake', '>= 0.6.0', '< 1.0.0'
  s.add_development_dependency 'rubocop-rspec', '>= 2.8.0', '< 3.0.0'
  s.add_development_dependency 'sqlite3-ruby', '>= 1.3.0', '< 1.4.0'
end
