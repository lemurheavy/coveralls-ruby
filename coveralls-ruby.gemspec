# -*- encoding: utf-8 -*-
require File.expand_path('../lib/coveralls/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Nick Merwin", "Wil Gieseler"]
  gem.email         = ["nick@lemurheavy.com", "supapuerco@gmail.com"]
  gem.description   = "A Ruby implementation of the Coveralls API."
  gem.summary       = "A Ruby implementation of the Coveralls API."
  gem.homepage      = "https://coveralls.io"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "coveralls"
  gem.require_paths = ["lib"]
  gem.version       = Coveralls::VERSION

  gem.add_dependency 'rest-client','~> 1.7'
  gem.add_dependency 'term-ansicolor', '~> 1.3'
  gem.add_dependency 'multi_json', '~> 1.10'
  gem.add_dependency 'thor', '~> 0.19.1'

  if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new("1.9")
    gem.add_dependency 'simplecov', '~> 0.9.1'
  end

  gem.add_dependency('jruby-openssl', '~> 0.9.5') if RUBY_PLATFORM == 'java'

  gem.add_development_dependency 'rspec', '~> 3.1'
  gem.add_development_dependency 'rake', '~> 10.4'
  gem.add_development_dependency 'webmock', '~> 1.20'
  gem.add_development_dependency 'vcr', '~> 2.9'
end
