Gem::Specification.new do |s|
  s.name = 'scoped_from'
  s.version = File.read(File.expand_path(File.dirname(__FILE__) + '/VERSION')).strip
  s.platform = Gem::Platform::RUBY
  s.author = 'Alexis Toulotte'
  s.email = 'al@alweb.org'
  s.homepage = 'https://github.com/alexistoulotte/scoped_from'
  s.summary = 'Mapping between scopes and parameters for Rails'
  s.description = 'Provides a simple mapping between Active Record scopes and controller parameters for Ruby On Rails 3'

  s.rubyforge_project = 'scoped_from'

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'activerecord', '~> 3.2.0'
  s.add_dependency 'activesupport', '~> 3.2.0'

  s.add_development_dependency 'byebug', '~> 1.6.0'
  s.add_development_dependency 'rake', '~> 10.0.0'
  s.add_development_dependency 'rspec', '~> 2.14.0'
  s.add_development_dependency 'sqlite3-ruby', '~> 1.3.0'
end
