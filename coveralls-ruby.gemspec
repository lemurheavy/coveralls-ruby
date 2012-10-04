# -*- encoding: utf-8 -*-
require File.expand_path('../lib/coveralls/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Wil Gieseler"]
  gem.email         = ["supapuerco@gmail.com"]
  gem.description   = %q{Write a gem description}
  gem.summary       = %q{Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "coveralls"
  gem.require_paths = ["lib"]
  gem.version       = Coveralls::VERSION

  gem.add_dependency 'rest-client'
  gem.add_dependency 'colorize'
  gem.add_dependency 'json'

  if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new("1.9")
    gem.add_dependency 'simplecov'
  end

  gem.add_runtime_dependency('jruby-openssl') if RUBY_PLATFORM == 'java'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rake'

end
