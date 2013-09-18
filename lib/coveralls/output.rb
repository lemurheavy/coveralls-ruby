module Coveralls
  #
  # Public: Methods for formatting strings with Term::ANSIColor.
  # Does not utilize monkey-patching and should play nicely when
  # included with other libraries.
  #
  # All methods are module methods and should be called on
  # the Coveralls::Output module.
  #
  # Examples
  #
  #   Coveralls::Output.format("Hello World", :color => "cyan")
  #   # => "\e[36mHello World\e[0m"
  #
  #   Coveralls::Output.print("Hello World")
  #   # Hello World => nil
  #
  #   Coveralls::Output.puts("Hello World", :color => "underline")
  #   # Hello World
  #   # => nil
  #
  # To silence output completely:
  #
  #   Coveralls::Output.silent = true
  #
  # or set this environment variable:
  #
  #   COVERALLS_SILENT

  module Output
    require 'term/ansicolor'
    attr_accessor :silent
    attr_writer :output
    extend self

    def output
      (defined?(@output) && @output) || $stdout
    end

    # Public: Formats the given string with the specified color
    # through Term::ANSIColor
    #
    # string  - the text to be formatted
    # options - The hash of options used for formatting the text:
    #           :color - The color to be passed as a method to
    #                    Term::ANSIColor
    #
    # Examples
    #
    #   Coveralls::Output.format("Hello World!", :color => "cyan")
    #   # => "\e[36mHello World\e[0m"
    #
    # Returns the formatted string.
    def format(string, options = {})
      if options[:color]
        options[:color].split(/\s/).reverse_each do |color|
          if Term::ANSIColor.respond_to?(color.to_sym)
            string = Term::ANSIColor.send(color.to_sym, string)
          end
        end
      end
      string
    end

    # Public: Passes .format to Kernel#puts
    #
    # string  - the text to be formatted
    # options - The hash of options used for formatting the text:
    #           :color - The color to be passed as a method to
    #                    Term::ANSIColor
    #
    #
    # Example
    #
    #   Coveralls::Output.puts("Hello World", :color => "cyan")
    #
    # Returns nil.
    def puts(string, options = {})
      return if silent?
      (options[:output] || output).puts self.format(string, options)
    end

    # Public: Passes .format to Kernel#print
    #
    # string  - the text to be formatted
    # options - The hash of options used for formatting the text:
    #           :color - The color to be passed as a method to
    #                    Term::ANSIColor
    #
    # Example
    #
    #   Coveralls::Output.print("Hello World!", :color => "underline")
    #
    # Returns nil.
    def print(string, options = {})
      return if silent?
      (options[:output] || output).print self.format(string, options)
    end

    def silent?
      ENV["COVERALLS_SILENT"] || (defined?(@silent) && @silent)
    end
  end
end
