require 'spec_helper'

describe Coveralls::SimpleCov::Formatter do

	it "fails unless we are on travis" do
		Coveralls::SimpleCov::Formatter.new.format(nil).should be_false
	end

end
