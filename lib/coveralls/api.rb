module Coveralls
	class API
		require 'httparty'
		require 'json'
		include HTTParty

		#base_uri "http://coveralls.herokuapp.com/api"
		base_uri "http://coveralls.dev/api/ruby"

		def self.post_json(endpoint, json)
			self.post("/" + endpoint, body: json.to_json)
		end
	
	end
end