require 'spec_helper'

describe Coveralls::Output do
  describe 'when silenced' do
    before do
      @original_stdout = $stdout
      @output = StringIO.new
      Coveralls::Output.silent = true
      $stdout = @output
    end
    it "should not puts" do
      Coveralls::Output.puts "foo"
      @output.rewind
      @output.read.should == ""
    end
    it "should not print" do
      Coveralls::Output.print "foo"
      @output.rewind
      @output.read.should == ""
    end
    after do
      $stdout = @original_stdout
    end
  end
  describe '.format' do
    it "accepts a color argument" do
      string = 'Hello'
      ansi_color_string =  Term::ANSIColor.red(string)
      Coveralls::Output.format(string, :color => 'red').should eq(ansi_color_string)
    end

    it "also accepts no color arguments" do
      unformatted_string = "Hi Doggie!"
      Coveralls::Output.format(unformatted_string).should eq(unformatted_string)
    end

    it "rejects formats unrecognized by Term::ANSIColor" do
      string = 'Hi dog!'
      Coveralls::Output.format(string, :color => "not_a_real_color").should eq(string)
    end

    it "accepts more than 1 color argument" do
      pending "Not implemented"

      string = 'Hi dog!'
      multi_formatted_string = Term::ANSIColor.red{ Term::ANSIColor.underline(string) }
      Coveralls::Output.format(string, :color => 'red underline').should eq(multi_formatted_string)
    end
  end
end
