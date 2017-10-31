source 'https://rubygems.org'

# Specify your gem's dependencies in coveralls-ruby.gemspec
gemspec

gem 'rake', '~> 12.0'
gem 'rspec', '~> 3.6'
gem 'simplecov', require: false
gem 'truthy', '~> 1.0'
gem 'vcr', '~> 3.0'
gem 'webmock', Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.0') ? '~> 2.3' : '~> 3.0'

platforms :ruby_19 do
  gem 'term-ansicolor', '~> 1.3.0'
  gem 'tins', '~> 1.6.0'
end

platforms :jruby do
  gem 'jruby-openssl'
end

platform :rbx do
  gem 'rubysl', '~> 2.0'
  gem 'rubinius-developer_tools'
end

group :test do
  gem 'pry'
end
