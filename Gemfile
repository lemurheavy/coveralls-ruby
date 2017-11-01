source 'https://rubygems.org'

# Specify your gem's dependencies in coveralls-ruby.gemspec
gemspec

gem 'rake', '~> 12.2'
gem 'rspec', '~> 3.7'
gem 'simplecov', '~> 0.15.1', require: false
gem 'truthy', '~> 1.0'
gem 'vcr', '~> 3.0'
gem 'webmock', '~> 3.1'

platforms :jruby do
  gem 'jruby-openssl', '~> 0.9.21'
end

platform :rbx do
  gem 'rubysl', '~> 2.2'
  gem 'rubinius-developer_tools', '~> 2.0'
end

group :test do
  gem 'pry', '~> 0.11.2'
end
