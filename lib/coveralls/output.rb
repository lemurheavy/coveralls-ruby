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
  module Output
    require 'term/ansicolor'
    extend self

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
      if options[:color] && Term::ANSIColor.respond_to?(options[:color].to_sym)
        Term::ANSIColor.send(options[:color].to_sym, string)
      else
        string
      end
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
      Kernel.puts self.format(string, options)
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
      Kernel.print self.format(string, options)
    end
  end
end
