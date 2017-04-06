require 'set'

module Dux
  # A set of strings or symbols (indifferently stored)
  # that can be used to validate options.
  #
  # Supports an optional default for when an invalid
  # element is fetched to act as a fallback rather
  # than raising an error.
  class Enum
    include Enumerable

    NO_DEFAULT = Dux.null 'Dux::Enum::NO_DEFAULT', purpose: 'When no default has been provided'

    private_constant :NO_DEFAULT

    def initialize(*values, default: NO_DEFAULT, allow_nil: false)
      @allow_nil = allow_nil

      set_values values

      set_default default
    end

    def default?
      @default != NO_DEFAULT
    end

    def each
      return enum_for(__method__) unless block_given?

      @values.each do |value|
        yield value
      end
    end

    def fetch(value, fallback: NO_DEFAULT)
      if include? value
        value
      elsif fallback != NO_DEFAULT
        if valid_fallback?(fallback)
          fallback
        else
          raise InvalidFallback, "Cannot use #{fallback.inspect} as a fallback"
        end
      elsif default?
        @default
      else
        raise NotFound, "Invalid enum member: #{value.inspect}"
      end
    end

    alias_method :[], :fetch

    def inspect
      inspection = [
        @values.to_a.inspect
      ]

      "Dux::Enum(#{@values.to_a.inspect})"
    end

    alias_method :has?, :include?
    alias_method :member?, :include?

    private

    def set_values(values)
      raise TypeError, "Must provide some values", caller if values.empty?

      @values = values.flatten.map do |value|
        Dux::IndifferentString.new value
      end.to_set
    end

    def valid_fallback?(fallback, default: false)
      return true if fallback.nil? && @allow_nil
      return true if include? fallback

      false
    end

    def set_default(fallback)
      if valid_fallback?(fallback) || fallback == NO_DEFAULT
        @default = fallback
      else
        raise InvalidFallback, "Cannot set #{fallback.inspect} as default", caller
      end
    end

    # Raised when there is no fallback
    class NotFound < StandardError
    end

    class InvalidFallback < ArgumentError
    end
  end
end
