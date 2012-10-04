module Coveralls
  module SimpleCov
    class Formatter

      def format(result)

        # Fail early if we're not on Travis
        unless ENV["TRAVIS"]
          puts "Coveralls currently only supports the Travis CI environment.".yellow
          return false
        end

        # Gather the source files.
        sources = {}
        result.files.each do |file|
          sources[file.filename] = File.open(file.filename, "rb").read
        end

        # Post to Coveralls.
        API.post_json "simplecov", {simplecov: result.to_hash, sources: sources}

        # Tell the world!
        puts output_message(result).green

        true

      rescue Exception => e 
        puts "Coveralls encountered an exception:".red
        puts e.to_s.red
        if e.response
          puts e.response.to_s.red
        end
      end

      def output_message(result)
        "Coverage is at #{result.covered_percent.round(2)}%.\nCoverage report sent to Coveralls."
      end

    end
  end
end