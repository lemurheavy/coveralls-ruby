source 'https://rubygems.org'

# Specify your gem's dependencies in coveralls-ruby.gemspec
gemspec

gem 'rake'
gem 'rspec', '>= 3.2'
gem 'simplecov', '~> 0.16.1', :require => false
gem 'truthy', '>= 1'

gem 'vcr', '>= 2.9'
gem 'webmock', '>= 1.20'

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
