module Coveralls
	module SimpleCov
		class Formatter

		  def format(result)
				API.post_json "simplecov", result.to_hash
		  end

		end
	end
end