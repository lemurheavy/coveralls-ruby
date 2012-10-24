module Coveralls
	class API

		require 'json'
		require 'rest_client'

		# API_BASE = "http://coveralls.dev/api/v1"
		API_BASE = "https://coveralls.io/api/v1"

		def self.post_json(endpoint, hash)
			url = endpoint_to_url(endpoint)
			# puts JSON.pretty_generate(hash).green
			hash = apified_hash hash
			RestClient.post(url, :json_file => hash_to_file(hash))
		end

		private

		def self.endpoint_to_url(endpoint)
			"#{API_BASE}/#{endpoint}"
		end

		def self.hash_to_file(hash)
			file = nil
			Tempfile.open(['coveralls-upload', 'json']) do |f|
				f.write(hash.to_json.to_s)
				file = f
			end
			File.new(file.path, 'rb')
		end

		def self.apified_hash hash
			config = Coveralls::Configuration.configuration
			puts "Submiting with config:".yellow
			puts JSON.pretty_generate(config).yellow
			hash.merge(config)
		end
	
	end
end