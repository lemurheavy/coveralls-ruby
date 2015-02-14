source 'https://rubygems.org'

# Specify your gem's dependencies in coveralls-ruby.gemspec
gemspec

platforms :ruby_18 do
  gem 'mime-types', '~> 1.25'
  gem 'rest-client', '~> 1.6.0'
end

platforms :jruby do
  gem 'jruby-openssl', '~> 0.9.5'
end

gem 'simplecov', :require => false
gem 'truthy'

platform :rbx do
  gem 'rubysl', '~> 2.0'
  gem 'json'
  gem 'rubinius-developer_tools'
end
