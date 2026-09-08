# frozen_string_literal: true

module Sample
  # A sample module used to validate RubySkimmer output.
  module Greeter
    # Builds a greeting string.
    #
    # @param name [String] the name to greet
    # @return [String] the greeting
    def self.greet name
      "Hello, #{name}!"
    end
  end

  # A sample class used to validate RubySkimmer output.
  class Widget
    # Creates a new Widget.
    def initialize label
      @label = label
    end

    # Returns the widget's label, formatted for display.
    def label
      "[#{@label}]"
    end
  end
end
