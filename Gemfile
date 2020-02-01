# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in coveralls-ruby.gemspec
gemspec

platforms :jruby do
  gem 'jruby-openssl', '~> 0.10.2'
end

group :development do
  gem 'rake', '~> 13.0'
  gem 'rspec', '~> 3.9'
  gem 'rubocop', '~> 0.79.0'
  gem 'rubocop-performance', '~> 1.5'
  gem 'rubocop-rspec', '~> 1.37'
  gem 'truthy', '~> 1.0'
  gem 'vcr', '~> 5.0'
  gem 'webmock', '~> 3.8'
end

group :development, :test do
  gem 'byebug', '~> 11.1', platforms: %i[mri mingw x64_mingw]
  gem 'pry', '~> 0.12.2'
  gem 'pry-byebug', '~> 3.8', platforms: %i[mri mingw x64_mingw]
end
