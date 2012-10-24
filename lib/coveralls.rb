require 'colorize'

require "coveralls/version"
require "coveralls/configuration"
require "coveralls/api"
require "coveralls/simplecov"

module Coveralls

  def self.wear!
    setup!
    start!
  end

  def self.setup!

    # Try to load up SimpleCov.
    @@adapter = nil
    if defined?(::SimpleCov)
      @@adapter = :simplecov
    else
      begin
        require 'simplecov'
        @@adapter = :simplecov if defined?(::SimpleCov)
      rescue
      end
    end

    # Load the appropriate adapter.
    if @@adapter == :simplecov
      ::SimpleCov.formatter = Coveralls::SimpleCov::Formatter
      puts "[Coveralls] Using the SimpleCov formatter.".green
    else
      puts "[Coveralls] Couldn't find an appropriate adapter.".red
    end

  end

  def self.start!
    if @@adapter == :simplecov
      if defined?(::Rails)
        puts "[Coveralls] Using SimpleCov's Rails settings.".green
        ::SimpleCov.start('rails')
      else
        ::SimpleCov.start
      end
    end
  end

  def self.should_run?

    # Fail early if we're not on Travis
    unless ENV["TRAVIS"]
      puts "[Coveralls] Not saving coverage run because we aren't on Travis CI.".yellow
      return false
    end

    true
  end

end