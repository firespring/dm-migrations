require File.expand_path('../lib/dm-migrations/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Dan Kubb']
  gem.email         = ['dan.kubb@gmail.com']
  gem.summary       = 'DataMapper plugin for writing and spec-ing migrations'
  gem.description   = gem.summary
  gem.homepage      = 'https://datamapper.org'

  gem.files         = `git ls-files`.split("\n")
  gem.extra_rdoc_files = %w(LICENSE README.rdoc)

  gem.name          = 'dm-migrations'
  gem.require_paths = ['lib']
  gem.version       = DataMapper::Migrations::VERSION

  gem.add_runtime_dependency('dm-core', '~> 1.3.0.beta')
end
