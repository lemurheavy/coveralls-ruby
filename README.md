# Coveralls for Ruby
Add the following to your Gemfile

    group :test do
      gem 'coveralls', require: false, github: 'lemurheavy/coveralls-ruby'
    end

If you use RSpec and SimpleCov, add the following to `spec/spec_helper.rb`

    require 'simplecov'
    require 'coveralls'

    SimpleCov.start 'rails'
    SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
      SimpleCov::Formatter::HTMLFormatter,
      Coveralls::SimpleCov::Formatter
    ]


<!---
TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'coveralls-ruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install coveralls-ruby

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
-->