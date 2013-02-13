require 'colorize'

require "coveralls/version"
require "coveralls/configuration"
require "coveralls/api"
require "coveralls/simplecov"

module Coveralls

  def self.wear!(*args)
    setup!
    start!(*args)
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
      puts "[Coveralls] Set up the SimpleCov formatter.".green
    else
      puts "[Coveralls] Couldn't find an appropriate adapter.".red
    end

  end

  def self.start!(simplecov_setting = 'test_frameworks')
    if @@adapter == :simplecov
      if simplecov_setting
        puts "[Coveralls] Using SimpleCov's '#{simplecov_setting}' settings.".green
        ::SimpleCov.start(simplecov_setting)
      else
        puts "[Coveralls] Using SimpleCov's default settings.".green
        ::SimpleCov.start
      end
    end
  end

  def self.should_run?

    # Fail early if we're not on a CI
    unless Coveralls::ServiceBase::ci?
      puts "[Coveralls] Outside the Travis environment, not sending data.".yellow
      return false
    end

    if running_locally?
      puts "[Coveralls] Creating a new job on Coveralls from local coverage results.".cyan
    end

    true
  end

  def running_locally?
    ENV["COVERALLS_RUN_LOCALLY"] == "true"
  end

end