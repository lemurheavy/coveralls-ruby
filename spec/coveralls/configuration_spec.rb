require 'spec_helper'

describe Coveralls::Configuration do
  before do
    ENV.stub(:[]).and_return(nil)
  end

  describe '.configuration' do
    it "returns a hash with the default keys" do
      config = Coveralls::Configuration.configuration
      config.should be_a(Hash)
      config.keys.should include(:environment)
      config.keys.should include(:git)
    end

    context 'yaml_config' do
      let(:repo_token) { SecureRandom.hex(4) }
      let(:repo_secret_token) { SecureRandom.hex(4) }
      let(:yaml_config) {
        {
          'repo_token' => repo_token,
          'repo_secret_token' => repo_secret_token
        }
      }

      before do
        Coveralls::Configuration.stub(:yaml_config).and_return(yaml_config)
      end

      it 'sets the Yaml config and associated variables if present' do
        config = Coveralls::Configuration.configuration
        config[:configuration].should eq(yaml_config)
        config[:repo_token].should eq(repo_token)
      end

      it 'uses the repo_secret_token if the repo_token is not set' do
        yaml_config.delete('repo_token')
        config = Coveralls::Configuration.configuration
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
        config = Coveralls::Configuration.configuration
        config[:repo_token].should eq(repo_token)
      end
    end

    context 'Services' do
      context 'on Travis' do
        before do
          ENV.stub(:[]).with('TRAVIS').and_return('1')
        end

        it 'should set service parameters for this service and no other' do
          Coveralls::Configuration.should_receive(:set_service_params_for_travis).with(anything, anything)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_circleci)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_semaphore)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_jenkins)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_coveralls_local)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_generic_ci)
          Coveralls::Configuration.configuration
        end
      end

      context 'on CircleCI' do
        before do
          ENV.stub(:[]).with('CIRCLECI').and_return('1')
        end

        it 'should set service parameters for this service and no other' do
          Coveralls::Configuration.should_not_receive(:set_service_params_for_travis)
          Coveralls::Configuration.should_receive(:set_service_params_for_circleci)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_semaphore)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_jenkins)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_coveralls_local)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_generic_ci)
          Coveralls::Configuration.configuration
        end
      end

      context 'on Semaphore' do
        before do
          ENV.stub(:[]).with('SEMAPHORE').and_return('1')
        end

        it 'should set service parameters for this service and no other' do
          Coveralls::Configuration.should_not_receive(:set_service_params_for_travis)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_circleci)
          Coveralls::Configuration.should_receive(:set_service_params_for_semaphore)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_jenkins)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_coveralls_local)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_generic_ci)
          Coveralls::Configuration.configuration
        end
      end

      context 'when using Jenkins' do
        before do
          ENV.stub(:[]).with('JENKINS_URL').and_return('1')
        end

        it 'should set service parameters for this service and no other' do
          Coveralls::Configuration.should_not_receive(:set_service_params_for_travis)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_circleci)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_semaphore)
          Coveralls::Configuration.should_receive(:set_service_params_for_jenkins)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_coveralls_local)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_generic_ci)
          Coveralls::Configuration.configuration
        end
      end

      context 'when running Coveralls locally' do
        before do
          ENV.stub(:[]).with('COVERALLS_RUN_LOCALLY').and_return('1')
        end

        it 'should set service parameters for this service and no other' do
          Coveralls::Configuration.should_not_receive(:set_service_params_for_travis)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_circleci)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_semaphore)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_jenkins)
          Coveralls::Configuration.should_receive(:set_service_params_for_coveralls_local)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_generic_ci)
          Coveralls::Configuration.configuration
        end
      end

      context 'for generic CI' do
        before do
          ENV.stub(:[]).with('CI_NAME').and_return('1')
        end

        it 'should set service parameters for this service and no other' do
          Coveralls::Configuration.should_not_receive(:set_service_params_for_travis)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_circleci)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_semaphore)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_jenkins)
          Coveralls::Configuration.should_not_receive(:set_service_params_for_coveralls_local)
          Coveralls::Configuration.should_receive(:set_service_params_for_generic_ci)
          Coveralls::Configuration.configuration
        end
      end
    end
  end

  describe '.set_service_params_for_travis' do
    let(:travis_job_id) { SecureRandom.hex(4) }
    before do
      ENV.stub(:[]).with('TRAVIS_JOB_ID').and_return(travis_job_id)
    end

    it 'should set the service_job_id' do
      config = {}
      Coveralls::Configuration.set_service_params_for_travis(config, nil)
      config[:service_job_id].should eq(travis_job_id)
    end

    it 'should set the service_name to travis-ci by default' do
      config = {}
      Coveralls::Configuration.set_service_params_for_travis(config, nil)
      config[:service_name].should eq('travis-ci')
    end

    it 'should set the service_name to a value if one is passed in' do
      config = {}
      service_name = SecureRandom.hex(4)
      Coveralls::Configuration.set_service_params_for_travis(config, service_name)
      config[:service_name].should eq(service_name)
    end
  end

  describe '.set_service_params_for_circleci' do
    let(:circle_build_num) { SecureRandom.hex(4) }
    before do
      ENV.stub(:[]).with('CIRCLE_BUILD_NUM').and_return(circle_build_num)
    end

    it 'should set the expected parameters' do
      config = {}
      Coveralls::Configuration.set_service_params_for_circleci(config)
      config[:service_name].should eq('circleci')
      config[:service_number].should eq(circle_build_num)
    end
  end

  describe '.set_service_params_for_semaphore' do
    let(:semaphore_build_num) { SecureRandom.hex(4) }
    before do
      ENV.stub(:[]).with('SEMAPHORE_BUILD_NUMBER').and_return(semaphore_build_num)
    end

    it 'should set the expected parameters' do
      config = {}
      Coveralls::Configuration.set_service_params_for_semaphore(config)
      config[:service_name].should eq('semaphore')
      config[:service_number].should eq(semaphore_build_num)
    end
  end

  describe '.set_service_params_for_jenkins' do
    let(:build_num) { SecureRandom.hex(4) }
    before do
      ENV.stub(:[]).with('BUILD_NUMBER').and_return(build_num)
    end

    it 'should set the expected parameters' do
      config = {}
      Coveralls::Configuration.set_service_params_for_jenkins(config)
      config[:service_name].should eq('jenkins')
      config[:service_number].should eq(build_num)
    end
  end

  describe '.set_service_params_for_coveralls_local' do
    it 'should set the expected parameters' do
      config = {}
      Coveralls::Configuration.set_service_params_for_coveralls_local(config)
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
    let(:service_pull_request) { SecureRandom.hex(4) }

    before do
      ENV.stub(:[]).with('CI_NAME').and_return(service_name)
      ENV.stub(:[]).with('CI_BUILD_NUMBER').and_return(service_number)
      ENV.stub(:[]).with('CI_BUILD_URL').and_return(service_build_url)
      ENV.stub(:[]).with('CI_BRANCH').and_return(service_branch)
      ENV.stub(:[]).with('CI_PULL_REQUEST').and_return(service_pull_request)
    end

    it 'should set the expected parameters' do
      config = {}
      Coveralls::Configuration.set_service_params_for_generic_ci(config)
      config[:service_name].should eq(service_name)
      config[:service_number].should eq(service_number)
      config[:service_build_url].should eq(service_build_url)
      config[:service_branch].should eq(service_branch)
      config[:service_pull_request].should eq(service_pull_request)
    end
  end
end
