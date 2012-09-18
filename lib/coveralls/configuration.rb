module Coveralls
  module Configuration

    require 'yaml'

    def self.configuration
      hash = {}
      if File.exists?(self.configuration_path)
        hash = YAML::load_file(self.configuration_path)
      end
      hash.merge(root: self.root, gem_version: VERSION, env: self.relevant_env)
    end

    def self.configuration_path
      File.expand_path File.join self.root, ".coveralls.yml"
    end

    def self.root
      ::SimpleCov.root
    end

    def self.relevant_env
      {travis_job_id: ENV['TRAVIS_JOB_ID']}
    end

  end
end