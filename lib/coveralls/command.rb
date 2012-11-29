module Coveralls
  require "thor"

  class CommandLine < Thor

    desc "push", "Runs your test suite and pushes the coverage results to Coveralls."
    def push
      return unless ensure_can_run_locally!
      ENV["COVERALLS_RUN_LOCALLY"] = "true"
      exec "bundle exec rake"
      ENV["COVERALLS_RUN_LOCALLY"] = nil
    end

    desc "report", "Runs your test suite locally and displays coverage statistics."
    def report
      ENV["COVERALLS_NOISY"] = "true"
      exec "bundle exec rake"
      ENV["COVERALLS_NOISY"] = nil
    end

    private

    def ensure_can_run_locally!
      config = Coveralls::Configuration.configuration
      if config[:repo_token].nil?
        puts "Coveralls cannot run locally because no repo_secret_token is set in .coveralls.yml".red
        puts "Please try again when you get your act together.".red
        return false
      end
      true
    end

  end
end