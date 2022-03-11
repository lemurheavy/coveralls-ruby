# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in coveralls-ruby.gemspec
gemspec

platforms :jruby do
  gem 'jruby-openssl', '~> 0.11.0'
end

gem 'rake', '~> 13.0'
gem 'rspec', '~> 3.11'
gem 'rubocop', '~> 1.26'
gem 'rubocop-performance', '~> 1.13'
gem 'rubocop-rake', '~> 0.6.0'
gem 'rubocop-rspec', '~> 2.9'
gem 'truthy', '~> 1.0'
gem 'vcr', '~> 6.0', github: 'vcr/vcr', ref: '9bb8d2c6f81a6720082a6db86ee11f4b82685d63' # TODO: revert to stable when Ruby 3.1 will be supported
gem 'webmock', '~> 3.14'
