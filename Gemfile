# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in coveralls-ruby.gemspec
gemspec

gem 'rake', '~> 12.2'
gem 'rspec', '~> 3.7'
gem 'rubocop', '~> 0.51.0'
gem 'rubocop-rspec', '~> 1.19'
gem 'simplecov', '~> 0.15.1', require: false
gem 'truthy', '~> 1.0'
gem 'vcr', '~> 3.0'
gem 'webmock', '~> 3.1'

platforms :jruby do
  gem 'jruby-openssl', '~> 0.9.21'
end

platform :rbx do
  gem 'rubinius-developer_tools', '~> 2.0'
  gem 'rubysl', '~> 2.2'
end

group :test do
  gem 'pry', '~> 0.11.2'
end
