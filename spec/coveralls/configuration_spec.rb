# frozen_string_literal: true

require 'spec_helper'

describe Coveralls::Configuration do
  before do
    ENV.stub(:[]).and_return(nil)
  end

  describe '.configuration' do
    it 'returns a hash with the default keys' do
      config = described_class.configuration
      config.should be_a(Hash)
      config.keys.should include(:environment)
      config.keys.should include(:git)
    end

    context 'yaml_config' do
      let(:repo_token) { SecureRandom.hex(4) }
      let(:repo_secret_token) { SecureRandom.hex(4) }
      let(:yaml_config) do
        {
          'repo_token' => repo_token,
          'repo_secret_token' => repo_secret_token
        }
      end

      before do
        described_class.stub(:yaml_config).and_return(yaml_config)
      end

      it 'sets the Yaml config and associated variables if present' do
        config = described_class.configuration
        config[:configuration].should eq(yaml_config)
        config[:repo_token].should eq(repo_token)
      end

      it 'uses the repo_secret_token if the repo_token is not set' do
        yaml_config.delete('repo_token')
        config = described_class.configuration
        config[:configuration].should eq(yaml_config)
        config[:repo_token].should eq(repo_secret_token)
      end
    end

    context 'repo_token in environment' do
      let(:repo_token) { SecureRandom.hex(4) }

      before do
        ENV.stub(:[]).with('COVERALLS_REPO_TOKEN').and_return(repo_token)
      end

      it 'pulls the repo token from the environment if set' do
        config = described_class.configuration
        config[:repo_token].should eq(repo_token)
      end
    end

    context 'parallel in environment' do
      before do
        ENV.stub(:[]).with('COVERALLS_PARALLEL').and_return(true)
      end

      it 'sets parallel to true if present' do
        config = described_class.configuration
        config[:parallel].should be true
      end
    end

    context 'Services' do
      context 'with env based service name' do
        let(:service_name) { 'travis-enterprise' }

        before do
          ENV.stub(:[]).with('TRAVIS').and_return('1')
          ENV.stub(:[]).with('COVERALLS_SERVICE_NAME').and_return(service_name)
        end

        it 'pulls the service name from the environment if set' do
          config = described_class.configuration
          config[:service_name].should eq(service_name)
        end
      end

      context 'on Travis' do
        before do
          ENV.stub(:[]).with('TRAVIS').and_return('1')
        end

        it 'sets service parameters for this service and no other' do
          described_class.should_receive(:set_service_params_for_travis).with(anything, anything)
          described_class.should_not_receive(:set_service_params_for_circleci)
          described_class.should_not_receive(:set_service_params_for_semaphore)
          described_class.should_not_receive(:set_service_params_for_jenkins)
          described_class.should_not_receive(:set_service_params_for_coveralls_local)
          described_class.should_receive(:set_standard_service_params_for_generic_ci)
          described_class.configuration
        end
      end

      context 'on CircleCI' do
        before do
          ENV.stub(:[]).with('CIRCLECI').and_return('1')
        end

        it 'sets service parameters for this service and no other' do
          described_class.should_not_receive(:set_service_params_for_travis)
          described_class.should_receive(:set_service_params_for_circleci)
          described_class.should_not_receive(:set_service_params_for_semaphore)
          described_class.should_not_receive(:set_service_params_for_jenkins)
          described_class.should_not_receive(:set_service_params_for_coveralls_local)
          described_class.should_receive(:set_standard_service_params_for_generic_ci)
          described_class.configuration
        end
      end

      context 'on Semaphore' do
        before do
          ENV.stub(:[]).with('SEMAPHORE').and_return('1')
        end

        it 'sets service parameters for this service and no other' do
          described_class.should_not_receive(:set_service_params_for_travis)
          described_class.should_not_receive(:set_service_params_for_circleci)
          described_class.should_receive(:set_service_params_for_semaphore)
          described_class.should_not_receive(:set_service_params_for_jenkins)
          described_class.should_not_receive(:set_service_params_for_coveralls_local)
          described_class.should_receive(:set_standard_service_params_for_generic_ci)
          described_class.configuration
        end
      end

      context 'when using Jenkins' do
        before do
          ENV.stub(:[]).with('JENKINS_URL').and_return('1')
        end

        it 'sets service parameters for this service and no other' do
          described_class.should_not_receive(:set_service_params_for_travis)
          described_class.should_not_receive(:set_service_params_for_circleci)
          described_class.should_not_receive(:set_service_params_for_semaphore)
          described_class.should_receive(:set_service_params_for_jenkins)
          described_class.should_not_receive(:set_service_params_for_coveralls_local)
          described_class.should_receive(:set_standard_service_params_for_generic_ci)
          described_class.configuration
        end
      end

      context 'when running Coveralls locally' do
        before do
          ENV.stub(:[]).with('COVERALLS_RUN_LOCALLY').and_return('1')
        end

        it 'sets service parameters for this service and no other' do
          described_class.should_not_receive(:set_service_params_for_travis)
          described_class.should_not_receive(:set_service_params_for_circleci)
          described_class.should_not_receive(:set_service_params_for_semaphore)
          described_class.should_not_receive(:set_service_params_for_jenkins)
          described_class.should_receive(:set_service_params_for_coveralls_local)
          described_class.should_receive(:set_standard_service_params_for_generic_ci)
          described_class.configuration
        end
      end

      context 'for generic CI' do
        before do
          ENV.stub(:[]).with('CI_NAME').and_return('1')
        end

        it 'sets service parameters for this service and no other' do
          described_class.should_not_receive(:set_service_params_for_travis)
          described_class.should_not_receive(:set_service_params_for_circleci)
          described_class.should_not_receive(:set_service_params_for_semaphore)
          described_class.should_not_receive(:set_service_params_for_jenkins)
          described_class.should_not_receive(:set_service_params_for_coveralls_local)
          described_class.should_receive(:set_standard_service_params_for_generic_ci).with(anything)
          described_class.configuration
        end
      end
    end
  end

  describe '.set_service_params_for_travis' do
    let(:travis_job_id) { SecureRandom.hex(4) }

    before do
      ENV.stub(:[]).with('TRAVIS_JOB_ID').and_return(travis_job_id)
    end

    it 'sets the service_job_id' do
      config = {}
      described_class.set_service_params_for_travis(config, nil)
      config[:service_job_id].should eq(travis_job_id)
    end

    it 'sets the service_name to travis-ci by default' do
      config = {}
      described_class.set_service_params_for_travis(config, nil)
      config[:service_name].should eq('travis-ci')
    end

    it 'sets the service_name to a value if one is passed in' do
      config = {}
      random_name = SecureRandom.hex(4)
      described_class.set_service_params_for_travis(config, random_name)
      config[:service_name].should eq(random_name)
    end
  end

  describe '.set_service_params_for_circleci' do
    let(:circle_build_num) { SecureRandom.hex(4) }

    before do
      ENV.stub(:[]).with('CIRCLE_BUILD_NUM').and_return(circle_build_num)
    end

    it 'sets the expected parameters' do
      config = {}
      described_class.set_service_params_for_circleci(config)
      config[:service_name].should eq('circleci')
      config[:service_number].should eq(circle_build_num)
    end
  end

  describe '.set_service_params_for_gitlab' do
    let(:commit_sha) { SecureRandom.hex(32) }
    let(:service_job_number) { 'spec:one' }
    let(:service_job_id) { 1234 }
    let(:service_branch) { 'feature' }

    before do
      ENV.stub(:[]).with('CI_BUILD_NAME').and_return(service_job_number)
      ENV.stub(:[]).with('CI_BUILD_ID').and_return(service_job_id)
      ENV.stub(:[]).with('CI_BUILD_REF_NAME').and_return(service_branch)
      ENV.stub(:[]).with('CI_BUILD_REF').and_return(commit_sha)
    end

    it 'sets the expected parameters' do
      config = {}
      described_class.set_service_params_for_gitlab(config)
      config[:service_name].should eq('gitlab-ci')
      config[:service_job_number].should eq(service_job_number)
      config[:service_job_id].should eq(service_job_id)
      config[:service_branch].should eq(service_branch)
      config[:commit_sha].should eq(commit_sha)
    end
  end

  describe '.set_service_params_for_semaphore' do
    let(:semaphore_build_num) { SecureRandom.hex(4) }

    before do
      ENV.stub(:[]).with('SEMAPHORE_BUILD_NUMBER').and_return(semaphore_build_num)
    end

    it 'sets the expected parameters' do
      config = {}
      described_class.set_service_params_for_semaphore(config)
      config[:service_name].should eq('semaphore')
      config[:service_number].should eq(semaphore_build_num)
    end
  end

  describe '.set_service_params_for_jenkins' do
    let(:service_pull_request) { '1234' }
    let(:build_num) { SecureRandom.hex(4) }

    before do
      ENV.stub(:[]).with('CI_PULL_REQUEST').and_return(service_pull_request)
      ENV.stub(:[]).with('BUILD_NUMBER').and_return(build_num)
    end

    it 'sets the expected parameters' do
      config = {}
      described_class.set_service_params_for_jenkins(config)
      described_class.set_standard_service_params_for_generic_ci(config)
      config[:service_name].should eq('jenkins')
      config[:service_number].should eq(build_num)
      config[:service_pull_request].should eq(service_pull_request)
    end
  end

  describe '.set_service_params_for_coveralls_local' do
    it 'sets the expected parameters' do
      config = {}
      described_class.set_service_params_for_coveralls_local(config)
      config[:service_name].should eq('coveralls-ruby')
      config[:service_job_id].should be_nil
      config[:service_event_type].should eq('manual')
    end
  end

  describe '.set_service_params_for_generic_ci' do
    let(:service_name) { SecureRandom.hex(4) }
    let(:service_number) { SecureRandom.hex(4) }
    let(:service_build_url) { SecureRandom.hex(4) }
    let(:service_branch) { SecureRandom.hex(4) }
    let(:service_pull_request) { '1234' }

    before do
      ENV.stub(:[]).with('CI_NAME').and_return(service_name)
      ENV.stub(:[]).with('CI_BUILD_NUMBER').and_return(service_number)
      ENV.stub(:[]).with('CI_BUILD_URL').and_return(service_build_url)
      ENV.stub(:[]).with('CI_BRANCH').and_return(service_branch)
      ENV.stub(:[]).with('CI_PULL_REQUEST').and_return(service_pull_request)
    end

    it 'sets the expected parameters' do
      config = {}
      described_class.set_standard_service_params_for_generic_ci(config)
      config[:service_name].should eq(service_name)
      config[:service_number].should eq(service_number)
      config[:service_build_url].should eq(service_build_url)
      config[:service_branch].should eq(service_branch)
      config[:service_pull_request].should eq(service_pull_request)
    end
  end

  describe '.set_service_params_for_appveyor' do
    let(:service_number) { SecureRandom.hex(4) }
    let(:service_branch) { SecureRandom.hex(4) }
    let(:commit_sha) { SecureRandom.hex(4) }
    let(:repo_name) { SecureRandom.hex(4) }

    before do
      ENV.stub(:[]).with('APPVEYOR_BUILD_VERSION').and_return(service_number)
      ENV.stub(:[]).with('APPVEYOR_REPO_BRANCH').and_return(service_branch)
      ENV.stub(:[]).with('APPVEYOR_REPO_COMMIT').and_return(commit_sha)
      ENV.stub(:[]).with('APPVEYOR_REPO_NAME').and_return(repo_name)
    end

    it 'sets the expected parameters' do
      config = {}
      described_class.set_service_params_for_appveyor(config)
      config[:service_name].should eq('appveyor')
      config[:service_number].should eq(service_number)
      config[:service_branch].should eq(service_branch)
      config[:commit_sha].should eq(commit_sha)
      config[:service_build_url].should eq(format('https://ci.appveyor.com/project/%s/build/%s', repo_name, service_number))
    end
  end

  describe '.set_service_params_for_tddium' do
    let(:service_number)       { SecureRandom.hex(4) }
    let(:service_job_number)   { SecureRandom.hex(4) }
    let(:service_pull_request) { SecureRandom.hex(4) }
    let(:service_branch)       { SecureRandom.hex(4) }

    before do
      ENV.stub(:[]).with('TDDIUM_SESSION_ID').and_return(service_number)
      ENV.stub(:[]).with('TDDIUM_TID').and_return(service_job_number)
      ENV.stub(:[]).with('TDDIUM_PR_ID').and_return(service_pull_request)
      ENV.stub(:[]).with('TDDIUM_CURRENT_BRANCH').and_return(service_branch)
    end

    it 'sets the expected parameters' do
      config = {}
      described_class.set_service_params_for_tddium(config)
      config[:service_name].should eq('tddium')
      config[:service_number].should eq(service_number)
      config[:service_job_number].should eq(service_job_number)
      config[:service_pull_request].should eq(service_pull_request)
      config[:service_branch].should eq(service_branch)
      config[:service_build_url].should eq(format('https://ci.solanolabs.com/reports/%s', service_number))
    end
  end

  describe '.git' do
    let(:git_id) { SecureRandom.hex(2) }
    let(:author_name) { SecureRandom.hex(4) }
    let(:author_email) { SecureRandom.hex(4) }
    let(:committer_name) { SecureRandom.hex(4) }
    let(:committer_email) { SecureRandom.hex(4) }
    let(:message) { SecureRandom.hex(4) }
    let(:branch) { SecureRandom.hex(4) }

    before do
      allow(ENV).to receive(:fetch).with('GIT_ID', anything).and_return(git_id)
      allow(ENV).to receive(:fetch).with('GIT_AUTHOR_NAME', anything).and_return(author_name)
      allow(ENV).to receive(:fetch).with('GIT_AUTHOR_EMAIL', anything).and_return(author_email)
      allow(ENV).to receive(:fetch).with('GIT_COMMITTER_NAME', anything).and_return(committer_name)
      allow(ENV).to receive(:fetch).with('GIT_COMMITTER_EMAIL', anything).and_return(committer_email)
      allow(ENV).to receive(:fetch).with('GIT_MESSAGE', anything).and_return(message)
      allow(ENV).to receive(:fetch).with('GIT_BRANCH', anything).and_return(branch)
    end

    it 'uses ENV vars' do
      config = described_class.git
      config[:head][:id].should eq(git_id)
      config[:head][:author_name].should eq(author_name)
      config[:head][:author_email].should eq(author_email)
      config[:head][:committer_name].should eq(committer_name)
      config[:head][:committer_email].should eq(committer_email)
      config[:head][:message].should eq(message)
      config[:branch].should eq(branch)
    end
  end
end
