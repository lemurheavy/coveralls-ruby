# frozen_string_literal: true

require 'spec_helper'

describe Coveralls do
  before do
    SimpleCov.stub(:start)
    stub_api_post
    described_class.testing = true
  end

  describe '#will_run?' do
    it 'checks CI environemnt variables' do
      described_class.will_run?.should be_truthy
    end

    context 'with CI disabled' do
      before do
        allow(ENV).to receive(:[])
        allow(ENV).to receive(:[]).with('COVERALLS_RUN_LOCALLY').and_return(nil)
        allow(ENV).to receive(:[]).with('CI').and_return(nil)
        described_class.testing = false
      end

      it 'indicates no run' do
        described_class.will_run?.should be_falsy
      end
    end
  end

  describe '#should_run?' do
    it 'outputs to stdout when running locally' do
      described_class.testing = false
      described_class.run_locally = true
      silence do
        described_class.should_run?
      end
    end
  end

  describe '#wear!' do
    it 'receives block' do
      ::SimpleCov.should_receive(:start)
      silence do
        subject.wear! do
          add_filter 's'
        end
      end
    end

    it 'uses string' do
      ::SimpleCov.should_receive(:start).with 'test_frameworks'
      silence do
        subject.wear! 'test_frameworks'
      end
    end

    it 'uses default' do
      ::SimpleCov.should_receive(:start).with no_args
      silence do
        subject.wear!
      end
      ::SimpleCov.filters.map(&:filter_argument).should include 'vendor'
    end
  end

  describe '#wear_merged!' do
    it 'sets formatter to NilFormatter' do
      ::SimpleCov.should_receive(:start).with 'rails'
      silence do
        subject.wear_merged! 'rails' do
          add_filter '/spec/'
        end
      end
      ::SimpleCov.formatter.should be Coveralls::NilFormatter
    end
  end

  describe '#push!' do
    it 'sends existing test results' do
      result = false
      silence do
        result = subject.push!
      end
      result.should be_truthy
    end
  end

  describe '#setup!' do
    it 'sets SimpleCov adapter' do
      SimpleCovTmp = SimpleCov
      Object.send :remove_const, :SimpleCov
      silence { subject.setup! }
      SimpleCov = SimpleCovTmp
    end
  end
end
