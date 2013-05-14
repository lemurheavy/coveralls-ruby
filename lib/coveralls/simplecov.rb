module Coveralls
  module SimpleCov
    class Formatter

      def display_result(result)
        # Log which files would be submitted.
        if result.files.length > 0
          puts "[Coveralls] Some handy coverage stats:"
        else
          Coveralls::Output.puts "[Coveralls] There are no covered files.", :color => "yellow"
        end
        result.files.each do |f|
          print "  * "
          Coveralls::Output.print short_filename(f.filename).to_s, :color => "cyan"
          Coveralls::Output.print " => ", :color => "white"
          cov = "#{f.covered_percent.round}%"
          if f.covered_percent > 90
            Coveralls::Output.print cov, :color => "green"
          elsif f.covered_percent > 80
            Coveralls::Output.print cov, :color => "yellow"
          else
            Coveralls::Output.print cov, :color => "red"
          end
          puts ""
        end
        true
      end

      def format(result)

        unless Coveralls.should_run?
          if Coveralls.noisy?
            display_result result
          end
          return
        end

        # Gather the source files.
        source_files = []
        result.files.each do |file|
          properties = {}

          # Get Source
          properties[:source] = File.open(file.filename, "rb:utf-8").read

          # Get the root-relative filename
          properties[:name] = short_filename(file.filename)

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
        puts output_message result

        true

      rescue Exception => e
        display_error e
      end

      def display_error(e)
        Coveralls::Output.puts "Coveralls encountered an exception:", :color => "red"
        Coveralls::Output.puts e.class.to_s, :color => "red"
        Coveralls::Output.puts e.message, :color => "red"
        e.backtrace.each do |line|
          Coveralls::Output.puts line, :color => "red"
        end if e.backtrace
        if e.respond_to?(:response) && e.response
          Coveralls::Output.puts e.response.to_s, :color => "red"
        end
        false
      end

      def output_message(result)
        "Coverage is at #{result.covered_percent.round(2)}%.\nCoverage report sent to Coveralls."
      end

      def short_filename(filename)
        filename = filename.gsub(::SimpleCov.root, '.').gsub(/^\.\//, '') if ::SimpleCov.root
        filename
      end

    end
  end
end
