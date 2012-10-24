require 'simplecov'

class InceptionFormatter
  def format(result)
    Coveralls::SimpleCov::Formatter.new.format(result)
  end
end

SimpleCov.formatter = InceptionFormatter
SimpleCov.start do
  add_filter 'spec'
end

require 'coveralls'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
