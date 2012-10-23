module Coveralls
  module SimpleCov
    class Formatter

      def format(result)

        return unless Coveralls.should_run?

        # Gather the source files.
        source_files = []
        result.files.each do |file|
          properties = {}

          # Get Source
          properties[:source] = File.open(file.filename, "rb").read

          # Get the root-relative filename
          filename = file.filename
          filename = filename.gsub(::SimpleCov.root, '.').gsub(/^\.\//, '') if ::SimpleCov.root
          properties[:name] = filename

          # Get the coverage
          properties[:coverage] = file.coverage

          # Get the group
          # puts "result groups: #{result.groups}"
          # result.groups.each do |group_name, grouped_files|
          #   puts "Checking #{grouped_files.map(&:filename)} for #{file.filename}"
          #   if grouped_files.map(&:filename).include?(file.filename)
          #     properties[:group] = group_name
          #     break
          #   end
          # end

          source_files << properties
        end

        # Log which files are being submitted.
        # puts "Submitting #{source_files.length} file#{source_files.length == 1 ? '' : 's'}:"
        # source_files.each do |f|
        #   puts "  => #{f[:name]}"
        # end

        # Post to Coveralls.
        API.post_json "jobs", {:source_files => source_files, :test_framework => result.command_name.downcase, :run_at => result.created_at}

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