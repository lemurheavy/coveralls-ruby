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
      Coveralls::Output.puts("#{ MultiJson.dump(hash, :pretty => true) }", :color => "green") if ENV['COVERALLS_DEBUG']
			hash = apified_hash hash
      Coveralls::Output.puts "[Coveralls] Submitting to #{API_BASE}", :color => "cyan"
			response = RestClient.post(url, :json_file => hash_to_file(hash))
			response_hash = MultiJson.load(response.to_str)
      Coveralls::Output.puts "[Coveralls] #{ response_hash['message'] }", :color => "cyan"
			if response_hash['message']
        Coveralls::Output.puts("[Coveralls] #{ Coveralls::Output.format(response_hash['url'], :color => "underline") }", :color => "cyan")
			end
		rescue RestClient::ServiceUnavailable
			Coveralls::Output.puts "[Coveralls] API timeout occured, but data should still be processed", :color => "red"
		rescue RestClient::InternalServerError
      Coveralls::Output.puts "[Coveralls] API internal error occured, we're on it!", :color => "red"
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
        Coveralls::Output.puts "[Coveralls] Submitting with config:", :color => "yellow"
        Coveralls::Output.puts MultiJson.dump(config, :pretty => true)
					.gsub(/"repo_token": "(.*?)"/,'"repo_token": "[secure]"'), :color => "yellow"
			end
			hash.merge(config)
		end
	end
end
