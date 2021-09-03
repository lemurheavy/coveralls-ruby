# coveralls-ruby [![Test Coverage](https://coveralls.io/repos/lemurheavy/coveralls-ruby/badge.svg?branch=master)](https://coveralls.io/r/lemurheavy/coveralls-ruby) [![Build Status](https://secure.travis-ci.org/lemurheavy/coveralls-ruby.svg?branch=master)](https://travis-ci.org/lemurheavy/coveralls-ruby) [![Gem Version](https://badge.fury.io/rb/coveralls.svg)](http://badge.fury.io/rb/coveralls)

[Coveralls.io](http://coveralls.io) was designed with Ruby projects in mind, so we've made it as easy as possible to get started using [Coveralls](http://coveralls.io) with Ruby and Rails project.

### PREREQUISITES

- Using a supported repo host ([GitHub](http://github.com/) | [Gitlab](https://gitlab.com/) | [Bitbucket](https://bitbucket.org/))
- Building on a supported CI service (see [supported CI services](https://docs.coveralls.io/supported-ci-services) here)
- Any Ruby project or test framework supported by [SimpleCov](https://github.com/colszowka/simplecov) is supported by the [coveralls-ruby](https://github.com/lemurheavy/coveralls-ruby) gem. This includes all your favorites, like [RSpec](http://rspec.info/), Cucumber, and Test::Unit.

*Please note that [SimpleCov](https://github.com/colszowka/simplecov) only supports Ruby 1.9 and later.*

### INSTALLING THE GEM

You shouldn't need more than a quick change to get your project on Coveralls. Just include [coveralls-ruby](https://github.com/lemurheavy/coveralls-ruby) in your project's Gemfile like so:

```ruby
# ./Gemfile

gem 'coveralls', require: false
```

While [SimpleCov](https://github.com/colszowka/simplecov) only supports Ruby 1.9+, using the Coveralls gem will not fail builds on earlier Rubies or other flavors of Ruby.

### CONFIGURATION

[coveralls-ruby](https://github.com/lemurheavy/coveralls-ruby) uses an optional `.coveralls.yml` file at the root level of your repository to configure options.

The option `repo_token` (found on your repository's page on Coveralls) is used to specify which project on Coveralls your project maps to.

Another important configuration option is `service_name`, which indicates your CI service and allows you to specify where Coveralls should look to find additional information about your builds. This can be any string, but using the appropriate string for your service may allow Coveralls to perform service-specific actions like fetching branch data and commenting on pull requests.

**Example: A .coveralls.yml file configured for Travis Pro:**

```yml
service_name: travis-pro
```

**Example: Passing `repo_token` from the command line:**

```
COVERALLS_REPO_TOKEN=asdfasdf bundle exec rspec spec
```

### TEST SUITE SETUP

After configuration, the next step is to add [coveralls-ruby](https://github.com/lemurheavy/coveralls-ruby) to your test suite.

For a Ruby app:

```ruby
# ./spec/spec_helper.rb
# ./test/test_helper.rb
# ..etc..

require 'coveralls'
Coveralls.wear!
```

For a Rails app:

```ruby
require 'coveralls'
Coveralls.wear!('rails')
```

**Note:** The `Coveralls.wear!` must occur before any of your application code is required, so it should be at the **very top** of your `spec_helper.rb`, `test_helper.rb`, or `env.rb`, etc.

And holy moly, you're done!

Next time your project is built on CI, [SimpleCov](https://github.com/colszowka/simplecov) will dial up [Coveralls.io](https://coveralls.io) and send the hot details on your code coverage.

### SIMPLECOV CUSTOMIZATION

*"But wait!"* you're saying, *"I already use SimpleCov, and I have some custom settings! Are you really just overriding everything I've already set up?"*

Good news, just use this gem's [SimpleCov](https://github.com/colszowka/simplecov) formatter directly:

```ruby
require 'simplecov'
require 'coveralls'

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter 'app/secrets'
end
```

Or alongside another formatter, like so:

```ruby
require 'simplecov'
require 'coveralls'

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start
```

### MERGING MULTIPLE TEST SUITES

If you're using more than one test suite and want the coverage results to be merged, use `Coveralls.wear_merged!` instead of `Coveralls.wear!`.

Or, if you're using Coveralls alongside another [SimpleCov](https://github.com/colszowka/simplecov) formatter, simply omit the Coveralls formatter, then add the rake task `coveralls:push` to your `Rakefile` as a dependency to your testing task, like so:

```ruby
require 'coveralls/rake/task'
Coveralls::RakeTask.new
task :test_with_coveralls => [:spec, :features, 'coveralls:push']
```

This will prevent Coveralls from sending coverage data after each individual suite, instead waiting until [SimpleCov](https://github.com/colszowka/simplecov) has merged the results, which are then posted to [Coveralls.io](https://coveralls.io).

Unless you've added `coveralls:push` to your default rake task, your build command will need to be updated on your CI to reflect this, for example:

```console
bundle exec rake :test_with_coveralls
```

*Read more about [SimpleCov's result merging](https://github.com/colszowka/simplecov#merging-results).*

### MANUAL BUILDS VIA CLI

[coveralls-ruby](https://github.com/lemurheavy/coveralls-ruby) also allows you to upload coverage data manually by running your test suite locally.

To do this with [RSpec](http://rspec.info/), just type `bundle exec coveralls push` in your project directory.

This will run [RSpec](http://rspec.info/) and upload the coverage data to [Coveralls.io](https://coveralls.io) as a one-off build, passing along any configuration options specified in `.coveralls.yml`.
