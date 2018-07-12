require 'spec_helper'

describe Coveralls::Configuration do
  before { ENV.stub(:[]).and_return(nil) }

  describe '.configuration' do
    it 'returns a hash with the default keys', :aggregate_failures do
      aggregate_failures 'correct_keys' do
        config = Coveralls::Configuration.configuration

        expect(config).to be_a(Hash)
        expect(config.keys).to include(:environment)
        expect(config.keys).to include(:git)
      end
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
        Coveralls::Configuration.stub(:yaml_config).and_return(yaml_config)
      end

      it 'sets the Yaml config and associated variables if present', :aggregate_failures do
        aggregate_failures 'successful_response' do
          config = Coveralls::Configuration.configuration

          expect(config[:configuration]).to eq(yaml_config)
          expect(config[:repo_token]).to eq(repo_token)
        end
      end

      it 'uses the repo_secret_token if the repo_token is not set', :aggregate_failures do
        aggregate_failures 'successful_response' do
          yaml_config.delete('repo_token')
          config = Coveralls::Configuration.configuration

          expect(config[:configuration]).to eq(yaml_config)
          expect(config[:repo_token]).to eq(repo_secret_token)
        end
      end
    end

    context 'repo_token in environment' do
      let(:repo_token) { SecureRandom.hex(4) }

      before do
        ENV.stub(:[]).with('COVERALLS_REPO_TOKEN').and_return(repo_token)
      end

      it 'pulls the repo token from the environment if set', :aggregate_failures do
        aggregate_failures 'successful_response' do
          config = Coveralls::Configuration.configuration

          expect(config[:repo_token]).to eq(repo_token)
        end
      end
    end

    context 'flag_name in environment' do
      let(:flag_name) { 'Test Flag' }

      before do
        ENV.stub(:[]).with('COVERALLS_FLAG_NAME').and_return(flag_name)
      end

      it 'pulls the flag name from the environment if set', :aggregate_failures do
        aggregate_failures 'successful_response' do
          config = Coveralls::Configuration.configuration

          expect(config[:flag_name]).to eq(flag_name)
        end
      end
    end

    context 'Services' do
      context 'with env based service name' do
        let(:service_name) { 'travis-enterprise' }
        before do
          ENV.stub(:[]).with('TRAVIS').and_return('1')
          ENV.stub(:[]).with('COVERALLS_SERVICE_NAME').and_return(service_name)
        end

        it 'pulls the service name from the environment if set', :aggregate_failures do
          aggregate_failures 'successful_response' do
            config = Coveralls::Configuration.configuration

            expect(config[:service_name]).to eq(service_name)
          end
        end
      end

      context 'on Travis' do
        before do
          ENV.stub(:[]).with('TRAVIS').and_return('1')
        end

        it 'should set service parameters for this service and no other', :aggregate_failures do
          aggregate_failures 'success' do
            Coveralls::Configuration.should_receive(:define_service_params_for_travis).with(anything, anything)
            Coveralls::Configuration.should_not_receive(:define_service_params_for_circleci)
            Coveralls::Configuration.should_not_receive(:define_service_params_for_semaphore)
            Coveralls::Configuration.should_not_receive(:define_service_params_for_jenkins)
            Coveralls::Configuration.should_not_receive(:define_service_params_for_coveralls_local)
            Coveralls::Configuration.should_receive(:define_standard_service_params_for_generic_ci)
            Coveralls::Configuration.configuration
          end
        end
      end

      context 'on CircleCI' do
        before do
          ENV.stub(:[]).with('CIRCLECI').and_return('1')
        end

        it 'should set service parameters for this service and no other', :aggregate_failures do
          aggregate_failures 'success' do
            Coveralls::Configuration.should_not_receive(:define_service_params_for_travis)
            Coveralls::Configuration.should_receive(:define_service_params_for_circleci)
            Coveralls::Configuration.should_not_receive(:define_service_params_for_semaphore)
            Coveralls::Configuration.should_not_receive(:define_service_params_for_jenkins)
            Coveralls::Configuration.should_not_receive(:define_service_params_for_coveralls_local)
            Coveralls::Configuration.should_receive(:define_standard_service_params_for_generic_ci)
            Coveralls::Configuration.configuration
          end
        end
      end

      context 'on Semaphore' do
        before do
          ENV.stub(:[]).with('SEMAPHORE').and_return('1')
        end

        it 'should set service parameters for this service and no other', :aggregate_failures do
          aggregate_failures 'success' do
            Coveralls::Configuration.should_not_receive(:define_service_params_for_travis)
            Coveralls::Configuration.should_not_receive(:define_service_params_for_circleci)
            Coveralls::Configuration.should_receive(:define_service_params_for_semaphore)
            Coveralls::Configuration.should_not_receive(:define_service_params_for_jenkins)
            Coveralls::Configuration.should_not_receive(:define_service_params_for_coveralls_local)
            Coveralls::Configuration.should_receive(:define_standard_service_params_for_generic_ci)
            Coveralls::Configuration.configuration
          end
        end
      end

      context 'when using Jenkins' do
        before do
          ENV.stub(:[]).with('JENKINS_URL').and_return('1')
        end

        it 'should set service parameters for this service and no other', :aggregate_failures do
          aggregate_failures 'success' do
            Coveralls::Configuration.should_not_receive(:define_service_params_for_travis)
            Coveralls::Configuration.should_not_receive(:define_service_params_for_circleci)
            Coveralls::Configuration.should_not_receive(:define_service_params_for_semaphore)
            Coveralls::Configuration.should_receive(:define_service_params_for_jenkins)
            Coveralls::Configuration.should_not_receive(:define_service_params_for_coveralls_local)
            Coveralls::Configuration.should_receive(:define_standard_service_params_for_generic_ci)
            Coveralls::Configuration.configuration
          end
        end
      end

      context 'when running Coveralls locally' do
        before do
          ENV.stub(:[]).with('COVERALLS_RUN_LOCALLY').and_return('1')
        end

        it 'should set service parameters for this service and no other', :aggregate_failures do
          aggregate_failures 'success' do
            Coveralls::Configuration.should_not_receive(:define_service_params_for_travis)
            Coveralls::Configuration.should_not_receive(:define_service_params_for_circleci)
            Coveralls::Configuration.should_not_receive(:define_service_params_for_semaphore)
            Coveralls::Configuration.should_not_receive(:define_service_params_for_jenkins)
            Coveralls::Configuration.should_receive(:define_service_params_for_coveralls_local)
            Coveralls::Configuration.should_receive(:define_standard_service_params_for_generic_ci)
            Coveralls::Configuration.configuration
          end
        end
      end

      context 'for generic CI' do
        before do
          ENV.stub(:[]).with('CI_NAME').and_return('1')
        end

        it 'should set service parameters for this service and no other', :aggregate_failures do
          aggregate_failures 'success' do
            Coveralls::Configuration.should_not_receive(:define_service_params_for_travis)
            Coveralls::Configuration.should_not_receive(:define_service_params_for_circleci)
            Coveralls::Configuration.should_not_receive(:define_service_params_for_semaphore)
            Coveralls::Configuration.should_not_receive(:define_service_params_for_jenkins)
            Coveralls::Configuration.should_not_receive(:define_service_params_for_coveralls_local)
            Coveralls::Configuration.should_receive(:define_standard_service_params_for_generic_ci).with(anything)
            Coveralls::Configuration.configuration
          end
        end
      end
    end
  end

  describe '.define_service_params_for_travis' do
    let(:travis_job_id) { SecureRandom.hex(4) }
    before do
      ENV.stub(:[]).with('TRAVIS_JOB_ID').and_return(travis_job_id)
    end

    it 'should set values properly', :aggregate_failures do
      aggregate_failures 'should set the service_job_id' do
        config = {}
        Coveralls::Configuration.define_service_params_for_travis(config, nil)
        expect(config[:service_job_id]).to eq(travis_job_id)
      end

      aggregate_failures 'should set the service_name to travis-ci by default' do
        config = {}
        Coveralls::Configuration.define_service_params_for_travis(config, nil)
        expect(config[:service_name]).to eq('travis-ci')
      end

      aggregate_failures 'should set the service_name to a value if one is passed in' do
        config = {}
        random_name = SecureRandom.hex(4)
        Coveralls::Configuration.define_service_params_for_travis(config, random_name)
        expect(config[:service_name]).to eq(random_name)
      end
    end
  end

  describe '.define_service_params_for_circleci' do
    let(:circle_build_num) { SecureRandom.hex(4) }
    before do
      ENV.stub(:[]).with('CIRCLE_BUILD_NUM').and_return(circle_build_num)
    end

    it 'should set the expected parameters', :aggregate_failures do
      aggregate_failures 'success' do
        config = {}
        Coveralls::Configuration.define_service_params_for_circleci(config)
        expect(config[:service_name]).to eq('circleci')
        expect(config[:service_number]).to eq(circle_build_num)
      end
    end
  end

  describe '.define_service_params_for_gitlab' do
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

    it 'should set the expected parameters', :aggregate_failures do
      aggregate_failures 'success' do
        config = {}
        Coveralls::Configuration.define_service_params_for_gitlab(config)
        expect(config[:service_name]).to eq('gitlab-ci')
        expect(config[:service_job_number]).to eq(service_job_number)
        expect(config[:service_job_id]).to eq(service_job_id)
        expect(config[:service_branch]).to eq(service_branch)
        expect(config[:commit_sha]).to eq(commit_sha)
      end
    end
  end

  describe '.define_service_params_for_semaphore' do
    let(:semaphore_build_num) { SecureRandom.hex(4) }
    before do
      ENV.stub(:[]).with('SEMAPHORE_BUILD_NUMBER').and_return(semaphore_build_num)
    end

    it 'should set the expected parameters', :aggregate_failures do
      aggregate_failures 'success' do
        config = {}
        Coveralls::Configuration.define_service_params_for_semaphore(config)
        expect(config[:service_name]).to eq('semaphore')
        expect(config[:service_number]).to eq(semaphore_build_num)
      end
    end
  end

  describe '.define_service_params_for_jenkins' do
    let(:service_pull_request) { '1234' }
    let(:build_num) { SecureRandom.hex(4) }

    before do
      ENV.stub(:[]).with('CI_PULL_REQUEST').and_return(service_pull_request)
      ENV.stub(:[]).with('BUILD_NUMBER').and_return(build_num)
    end

    it 'should set the expected parameters', :aggregate_failures do
      aggregate_failures 'success' do
        config = {}
        Coveralls::Configuration.define_service_params_for_jenkins(config)
        Coveralls::Configuration.define_standard_service_params_for_generic_ci(config)
        expect(config[:service_name]).to eq('jenkins')
        expect(config[:service_number]).to eq(build_num)
        expect(config[:service_pull_request]).to eq(service_pull_request)
      end
    end
  end

  describe '.define_service_params_for_coveralls_local' do
    it 'should set the expected parameters', :aggregate_failures do
      aggregate_failures 'success' do
        config = {}
        Coveralls::Configuration.define_service_params_for_coveralls_local(config)
        expect(config[:service_name]).to eq('coveralls-ruby')
        expect(config[:service_job_id]).to be_nil
        expect(config[:service_event_type]).to eq('manual')
      end
    end
  end

  describe '.define_service_params_for_generic_ci' do
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

    it 'should set the expected parameters', :aggregate_failures do
      aggregate_failures 'success' do
        config = {}
        Coveralls::Configuration.define_standard_service_params_for_generic_ci(config)
        expect(config[:service_name]).to eq(service_name)
        expect(config[:service_number]).to eq(service_number)
        expect(config[:service_build_url]).to eq(service_build_url)
        expect(config[:service_branch]).to eq(service_branch)
        expect(config[:service_pull_request]).to eq(service_pull_request)
      end
    end
  end

  describe '.define_service_params_for_appveyor' do
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

    it 'should set the expected parameters', :aggregate_failures do
      aggregate_failures 'success' do
        config = {}
        Coveralls::Configuration.define_service_params_for_appveyor(config)
        expect(config[:service_name]).to eq('appveyor')
        expect(config[:service_number]).to eq(service_number)
        expect(config[:service_branch]).to eq(service_branch)
        expect(config[:commit_sha]).to eq(commit_sha)
        expect(config[:service_build_url]).to eq(format('https://ci.appveyor.com/project/%s/build/%s', repo_name, service_number))
      end
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

    it 'uses ENV vars', :aggregate_failures do
      aggregate_failures 'success' do
        config = Coveralls::Configuration.git
        expect(config[:head][:id]).to eq(git_id)
        expect(config[:head][:author_name]).to eq(author_name)
        expect(config[:head][:author_email]).to eq(author_email)
        expect(config[:head][:committer_name]).to eq(committer_name)
        expect(config[:head][:committer_email]).to eq(committer_email)
        expect(config[:head][:message]).to eq(message)
        expect(config[:branch]).to eq(branch)
      end
    end
  end
end
