require 'colorize'

require "coveralls/version"
require "coveralls/configuration"
require "coveralls/api"
require "coveralls/simplecov"

module Coveralls
  extend self

  class NilFormatter
    def format( result )
    end
  end

  attr_accessor :testing, :noisy, :adapter, :run_locally

  def wear!(simplecov_setting=nil, &block)
    setup!
    start! simplecov_setting, &block
  end

  def wear_merged!(simplecov_setting=nil, &block)
    require 'simplecov'
    @@adapter = :simplecov
    ::SimpleCov.formatter = NilFormatter
    start! simplecov_setting, &block
  end

  def push!
    require 'simplecov'
    result = ::SimpleCov::ResultMerger.merged_result
    Coveralls::SimpleCov::Formatter.new.format result
  end

  def setup!
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

  def start!(simplecov_setting = 'test_frameworks', &block)
    if @@adapter == :simplecov
      ::SimpleCov.add_filter 'vendor'

      if simplecov_setting
        puts "[Coveralls] Using SimpleCov's '#{simplecov_setting}' settings.".green
        if block_given?
          ::SimpleCov.start(simplecov_setting) { instance_eval(&block)}
        else
          ::SimpleCov.start(simplecov_setting)
        end
      elsif block_given?
        puts "[Coveralls] Using SimpleCov settings defined in block.".green
        ::SimpleCov.start { instance_eval(&block) }
      else
        puts "[Coveralls] Using SimpleCov's default settings.".green
        ::SimpleCov.start
      end
    end
  end

  def should_run?
    # Fail early if we're not on a CI
    unless ENV["CI"] || ENV["JENKINS_URL"] ||
      ENV["COVERALLS_RUN_LOCALLY"] || (defined?(@testing) && @testing)
      puts "[Coveralls] Outside the Travis environment, not sending data.".yellow
      return false
    end

    if ENV["COVERALLS_RUN_LOCALLY"] || (defined?(@run_locally) && @run_locally)
      puts "[Coveralls] Creating a new job on Coveralls from local coverage results.".cyan
    end

    true
  end

  def noisy?
    ENV["COVERALLS_NOISY"] || (defined?(@noisy) && @noisy)
  end
end
