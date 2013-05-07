module Coveralls
	class API

		require 'multi_json'
		require 'rest_client'

		API_HOST = ENV['COVERALLS_DEVELOPMENT'] ? "localhost:3000" : "coveralls.io"
		API_PROTOCOL = ENV['COVERALLS_DEVELOPMENT'] ? "http" : "https"
		API_DOMAIN = "#{API_PROTOCOL}://#{API_HOST}"
		API_BASE = "#{API_DOMAIN}/api/v1"

		def self.post_json(endpoint, hash)
			disable_net_blockers!
			url = endpoint_to_url(endpoint)
			puts ColorFormat.green("#{ MultiJson.dump(hash, :pretty => true) }") if ENV['COVERALLS_DEBUG']
			hash = apified_hash hash
			puts ColorFormat.cyan("[Coveralls] Submitting to #{API_BASE}")
			response = RestClient.post(url, :json_file => hash_to_file(hash))
			response_hash = MultiJson.load(response.to_str)
			puts ColorFormat.cyan("[Coveralls] " + response_hash['message'])
			if response_hash['message']
				puts ColorFormat.cyan("[Coveralls] " + ColorFormat.underline(response_hash['url']))
			end
		rescue RestClient::ServiceUnavailable
			puts ColorFormat.red("[Coveralls] API timeout occured, but data should still be processed")
		rescue RestClient::InternalServerError
			puts ColorFormat.red("[Coveralls] API internal error occured, we're on it!")
		end

		private

		def self.disable_net_blockers!
			if defined?(WebMock) &&
			  allow = WebMock::Config.instance.allow || []
			  WebMock::Config.instance.allow = [*allow].push API_HOST
			end

			if defined?(VCR)
				VCR.send(VCR.version.major < 2 ? :config : :configure) do |c|
          c.ignore_hosts API_HOST
				end
			end
		end

		def self.endpoint_to_url(endpoint)
			"#{API_BASE}/#{endpoint}"
		end

		def self.hash_to_file(hash)
			file = nil
			Tempfile.open(['coveralls-upload', 'json']) do |f|
				f.write(MultiJson.dump hash)
				file = f
			end
			File.new(file.path, 'rb')
		end

		def self.apified_hash hash
			config = Coveralls::Configuration.configuration
			if ENV['CI'] || ENV['COVERALLS_DEBUG'] || Coveralls.testing
				puts ColorFormat.yellow("[Coveralls] Submiting with config:")
				puts ColorFormat.yellow(MultiJson.dump(config, :pretty => true).
					gsub(/"repo_token": "(.*?)"/,'"repo_token": "[secure]"'))
			end
			hash.merge(config)
		end
	end
end
