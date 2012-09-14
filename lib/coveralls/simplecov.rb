module Coveralls
	module SimpleCov
		class Formatter

			def format(result)
				sources = {}
				result.files.each do |file|
					sources[file.filename] = File.open(file.filename, "rb").read
				end
				API.post_json "simplecov", {simplecov: result.to_hash, sources: sources}
			end

		end
	end
end