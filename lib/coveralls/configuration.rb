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
      pwd
    end

    def self.pwd
      Dir.pwd
    end

    def self.simplecov_root
      ::SimpleCov.root
    end

    def self.rails_root
      Rails.root.to_s
    rescue
      nil
    end

    def self.git
      repo = Grit::Repo.new(root)
      head = Grit::Head.current(repo)

      hash = {}

      if head
        hash[:head] = {id: head.commit.id, message: head.commit.message}
        hash[:branch] = head.name
      end

      #remotes
      remotes = nil
      begin
        Dir.chdir(root) do
          remotes = `git remote -v`.split(/\n/).map do |remote|
            splits = remote.split(" ").compact
            {name: splits[0], url: splits[1]}
          end.uniq
        end
      rescue
      end
      hash[:remotes] = remotes

      begin
        Dir.chdir(root) do
          hash[:show_refs] = `git show-ref`.split(/\n/)
        end 
      rescue
      end

      hash

    rescue Exception => e
      puts "Coveralls git error:".red
      puts e.to_s.red
      nil
    end

    def self.relevant_env
      {travis_job_id: ENV['TRAVIS_JOB_ID'], pwd: self.pwd, rails_root: self.rails_root, simplecov_root: simplecov_root, gem_version: VERSION, dump: ENV.to_hash}
    end

  end
end