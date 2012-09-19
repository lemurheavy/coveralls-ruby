module Coveralls
  module Configuration

    require 'yaml'
    require 'grit'

    def self.configuration
      hash = nil
      if self.configuration_path && File.exists?(self.configuration_path)
        hash = YAML::load_file(self.configuration_path)
      end
      {environment: self.relevant_env, configuration: hash, git: git}
    end

    def self.configuration_path
      File.expand_path(File.join(self.root, ".coveralls.yml")) if self.root
    end

    def self.root
      rails_root || pwd
    end

    def self.pwd
      Dir.pwd
    end

    def self.simplecov_root
      ::SimpleCov.root
    end

    def self.rails_root
      Rails.root
    rescue
      nil
    end

    def self.git
      repo = Grit::Repo.new(root)
      head = Grit::Head.current(repo)

      #remotes
      remotes = nil
      begin
        Dir.chdir(repo.git.git_dir) do
          remotes = `git remote -v`.split(/\n/).map do |remote|
            splits = remote.split(" ").compact
            {name: splits[0], url: splits[1]}
          end.uniq
        end
      rescue
      end

      {head: {id: head.commit.id, message: head.commit.message}, branch: head.name, remotes: remotes}
    rescue Exception => e
      puts "Coveralls git error:".red
      puts e.to_s.red
      nil
    end

    def self.relevant_env
      {travis_job_id: ENV['TRAVIS_JOB_ID'], pwd: self.pwd, rails_root: self.rails_root, simplecov_root: simplecov_root, gem_version: VERSION}
    end

  end
end