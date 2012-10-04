require 'colorize'

require "coveralls/version"
require "coveralls/configuration"
require "coveralls/api"
require "coveralls/simplecov"

module Coveralls

  def self.wear!

    # Try to load up SimpleCov.
    adapter = nil
    if defined?(::SimpleCov)
      adapter = :simplecov
    else
      begin
        require 'simplecov'
        adapter = :simplecov if defined?(::SimpleCov)
      rescue
      end
    end

    # Load the appropriate adapter.
    if adapter == :simplecov
      ::SimpleCov.start
      ::SimpleCov.formatter = Coveralls::SimpleCov::Formatter
      puts "Coveralls is using the SimpleCov formatter.".green
    else
      puts "Coveralls couldn't find an appropriate adapter.".red
    end

  end

  def self.should_run?

    # Fail early if we're not on Travis
    unless ENV["TRAVIS"]
      puts "Coveralls currently only supports the Travis CI environment.".yellow
      return false
    end

    true
  end

end