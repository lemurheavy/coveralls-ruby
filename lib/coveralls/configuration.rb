module Coveralls
  module Configuration

    require 'yaml'

    def self.configuration
      config = {
        :environment => self.relevant_env,
        :git => git
      }
      yml = self.yaml_config
      if yml
        config[:configuration] = yml
        config[:repo_token] = yml['repo_token'] || yml['repo_secret_token']
      end
      if ENV['COVERALLS_REPO_TOKEN']
        config[:repo_token] = ENV['COVERALLS_REPO_TOKEN']
      end
      if ENV['TRAVIS']
        config[:service_job_id] = ENV['TRAVIS_JOB_ID']
        config[:service_name]   = (yml ? yml['service_name'] : nil) || 'travis-ci'
      elsif ENV['CIRCLECI']
        config[:service_name]   = 'circleci'
        config[:service_number] = ENV['CIRCLE_BUILD_NUM']
      elsif ENV['SEMAPHORE']
        config[:service_name]   = 'semaphore'
        config[:service_number] = ENV['SEMAPHORE_BUILD_NUMBER']
      elsif ENV['JENKINS_URL']
        config[:service_name]   = 'jenkins'
        config[:service_number] = ENV['BUILD_NUMBER']
      elsif ENV["COVERALLS_RUN_LOCALLY"] || Coveralls.testing
        config[:service_job_id] = nil
        config[:service_name]   = 'coveralls-ruby'
        config[:service_event_type] = 'manual'

      # standardized env vars
      elsif ENV['CI_NAME']
        config[:service_name]         = ENV['CI_NAME']
        config[:service_number]       = ENV['CI_BUILD_NUMBER']
        config[:service_build_url]    = ENV['CI_BUILD_URL']
        config[:service_branch]       = ENV['CI_BRANCH']
        config[:service_pull_request] = ENV['CI_PULL_REQUEST']
      end

      config
    end

    def self.yaml_config
      if self.configuration_path && File.exists?(self.configuration_path)
        YAML::load_file(self.configuration_path)
      end
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
      if defined?(::SimpleCov)
        ::SimpleCov.root
      end
    end

    def self.rails_root
      Rails.root.to_s
    rescue
      nil
    end

    def self.git
      hash = {}

      Dir.chdir(root) do

        hash[:head] = {
          :id => `git log -1 --pretty=format:'%H'`,
          :author_name => `git log -1 --pretty=format:'%aN'`,
          :author_email => `git log -1 --pretty=format:'%ae'`,
          :committer_name => `git log -1 --pretty=format:'%cN'`,
          :committer_email => `git log -1 --pretty=format:'%ce'`,
          :message => `git log -1 --pretty=format:'%s'`
        }

        # Branch
        branch = `git branch`.split("\n").delete_if { |i| i[0] != "*" }
        hash[:branch] = [branch].flatten.first.gsub("* ","")

        # Remotes
        remotes = nil
        begin
          remotes = `git remote -v`.split(/\n/).map do |remote|
            splits = remote.split(" ").compact
            {:name => splits[0], :url => splits[1]}
          end.uniq
        rescue
        end
        hash[:remotes] = remotes

      end

      hash

    rescue Exception => e
      Coveralls::Output.puts "Coveralls git error:", :color => "red"
      Coveralls::Output.puts e.to_s, :color => "red"
      nil
    end

    def self.relevant_env
      hash = {
        :pwd => self.pwd,
        :rails_root => self.rails_root,
        :simplecov_root => simplecov_root,
        :gem_version => VERSION
      }

      hash.merge! begin
        if ENV['TRAVIS']
          {
            :travis_job_id => ENV['TRAVIS_JOB_ID'],
            :travis_pull_request => ENV['TRAVIS_PULL_REQUEST']
          }
        elsif ENV['CIRCLECI']
          {
            :circleci_build_num => ENV['CIRCLE_BUILD_NUM'],
            :branch => ENV['CIRCLE_BRANCH'],
            :commit_sha => ENV['CIRCLE_SHA1']
          }
        elsif ENV['JENKINS_URL']
          {
            :jenkins_build_num => ENV['BUILD_NUMBER'],
            :jenkins_build_url => ENV['BUILD_URL'],
            :branch => ENV['GIT_BRANCH'],
            :commit_sha => ENV['GIT_COMMIT']
          }
        else
          {}
        end
      end

      hash
    end

  end
end
