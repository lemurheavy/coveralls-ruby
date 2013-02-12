module Coveralls
	class API

		require 'json'
		require 'rest_client'

		# API_BASE = "http://coveralls.dev/api/v1"
		API_BASE = "https://coveralls.io/api/v1"

		def self.post_json(endpoint, hash)
			url = endpoint_to_url(endpoint)
			puts JSON.pretty_generate(hash).green if ENV['COVERALLS_DEBUG']
			hash = apified_hash hash
			puts "[Coveralls] Submitting to #{API_BASE}".cyan
			response = RestClient.post(url, :json_file => hash_to_file(hash))
			response_hash = JSON.parse response.to_str
			puts ("[Coveralls] " + response_hash['message']).cyan
			if response_hash['message']
				puts ("[Coveralls] " + response_hash['url'].underline).cyan
			end
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
			if ENV['TRAVIS'] || ENV['COVERALLS_DEBUG']
				puts "[Coveralls] Submiting with config:".yellow
				puts JSON.pretty_generate(config).
					gsub(/"repo_token": "(.*?)"/,'"repo_token": "[secure]"').yellow
			end
			hash.merge(config)
		end
	
	end
end