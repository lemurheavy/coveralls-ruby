require 'spec_helper'

describe Coveralls::Configuration do

  it "asserts true" do
    config = Coveralls::Configuration.configuration
    config.should_not be_nil
  end

end
