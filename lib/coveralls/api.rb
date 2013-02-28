module Coveralls
	class API

		require 'json'
		require 'rest_client'

		API_HOST = ENV['COVERALLS_DEVELOPMENT'] ? "localhost:3000" : "coveralls.io"
		API_PROTOCOL = ENV['COVERALLS_DEVELOPMENT'] ? "http" : "https"
		API_DOMAIN = "#{API_PROTOCOL}://#{API_HOST}"
		API_BASE = "#{API_DOMAIN}/api/v1"

		def self.post_json(endpoint, hash)
			disable_net_blockers!
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
		rescue RestClient::ServiceUnavailable
			puts ("[Coveralls] API timeout occured, but data should still be processed").red
		rescue RestClient::InternalServerError
			puts ("[Coveralls] API internal error occured, we're on it!").red
		end

		private

		def self.disable_net_blockers!
			if defined?(WebMock)
			  (WebMock::Config.instance.allow ||= []).push API_HOST
			end

			if defined?(VCR)
				VCR.configure do |c|
				  c.ignore_request do |request|
				    URI(request.uri).host == API_HOST
				  end
				end
			end
		end

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