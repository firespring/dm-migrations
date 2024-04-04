require File.expand_path('../lib/dm-migrations/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Dan Kubb']
  gem.email         = ['dan.kubb@gmail.com']
  gem.summary       = 'DataMapper plugin for writing and spec-ing migrations'
  gem.description   = 'DataMapper plugin for modifying and maintaining database structure, triggers, stored procedures, and data'
  gem.homepage      = 'https://datamapper.org'
  gem.license = 'Nonstandard'

  gem.files = `git ls-files`.split("\n")
  gem.extra_rdoc_files = %w(LICENSE README.rdoc)

  gem.name          = 'dm-migrations'
  gem.require_paths = ['lib']
  gem.version       = DataMapper::Migrations::VERSION
  gem.required_ruby_version = '>= 2.7.8'

  gem.add_runtime_dependency('dm-core', '~> 1.3.0.beta')
end
