module Coveralls
  module Configuration

    require 'yaml'
    require 'grit'

    def self.configuration
      hash = {}
      if File.exists?(self.configuration_path)
        hash = YAML::load_file(self.configuration_path)
      end
      {configuration: hash.merge(root: self.root, gem_version: VERSION, env: self.relevant_env), git: git}
    end

    def self.configuration_path
      File.expand_path File.join self.root, ".coveralls.yml"
    end

    def self.root
      ::SimpleCov.root
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
      {travis_job_id: ENV['TRAVIS_JOB_ID']}
    end

  end
end