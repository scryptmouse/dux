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

    # {Dux::NullObject} to determine if we have no default value.
    NO_DEFAULT = Dux.null 'Dux::Enum::NO_DEFAULT', purpose: 'When no default has been provided'

    private_constant :NO_DEFAULT

    # Types that can be specified for a return type
    RETURN_TYPES = %i[symbol string].freeze

    private_constant :RETURN_TYPES

    def initialize(*values, default: NO_DEFAULT, allow_nil: false, aliases: {}, return_type: :symbol)
      @allow_nil = allow_nil

      set_return_type return_type

      set_values values

      set_default default

      set_aliases aliases

      freeze
    end

    # Test for inclusion with case equality
    #
    # @param [String, Symbol] other
    def ===(other)
      include? other
    end

    # Check if the provided key is an alias.
    #
    # @param [Symbol, String] key
    def alias?(key)
      @aliases.key? key
    end

    # Check if we allow nil to be returned
    # as a default / fallback.
    def allow_nil?
      @allow_nil
    end

    # Check if a default is set for this enum.
    def default?
      @default != NO_DEFAULT
    end

    # @yield [value] each member of the enum
    # @yieldparam [Dux::IndifferentString] value
    def each
      return enum_for(__method__) unless block_given?

      @values.each do |value|
        yield value
      end
    end

    # @param [String, Symbol] value
    # @param [String, Symbol] fallback
    # @yield Executed in lieu of raising {Dux::Enum::NotFound} if there is an unknown member
    # @raise [Dux::Enum::InvalidFallback] when provided with an invalid override fallback value
    # @raise [Dux::Enum::NotFound] when fetching a value not found in the enum
    # @return [Symbol]
    def fetch(value, fallback: NO_DEFAULT)
      if include? value
        with_return_type value
      elsif alias?(value)
        with_return_type @aliases.fetch(value)
      elsif fallback != NO_DEFAULT
        if valid_fallback?(fallback)
          fallback
        else
          raise InvalidFallback, "Cannot use #{fallback.inspect} as a fallback"
        end
      elsif default?
        with_return_type @default
      else
        if block_given?
          yield value
        else
          raise NotFound, "Invalid enum member: #{value.inspect}"
        end
      end
    end

    alias_method :[], :fetch

    # @return [String]
    def inspect
      "Dux::Enum(#{@values.to_a.inspect})"
    end

    alias_method :has?, :include?
    alias_method :member?, :include?

    private

    # Ensure the value is returned with the correct type
    # @param [String, Symbol, nil] value
    # @return [String, Symbol, nil]
    def with_return_type(value)
      if value.nil? && allow_nil?
        if allow_nil?
          nil
        else
          # :nocov:
          raise ArgumentError, "Cannot return `nil` without allow_nil: true"
          # :nocov:
        end
      elsif @return_type == :symbol
        value.to_sym
      elsif @return_type == :string
        value.to_s
      end
    end

    # @param [Symbol] return_type
    # @raise [ArgumentError] on improper return type
    # @return [void]
    def set_return_type(return_type)
      if RETURN_TYPES.include? return_type
        @return_type = return_type
      else
        raise ArgumentError, "Invalid return type: #{return_type.inspect}", caller
      end
    end

    # @param [<String, Symbol>] values
    # @raise [TypeError] if provided with no values
    # @return [void]
    def set_values(values)
      raise TypeError, "Must provide some values", caller if values.empty?

      @values = values.flatten.map do |value|
        Dux::IndifferentString.new value
      end.to_set.freeze
    end

    # @param [{Symbol => String, Symbol}] aliases
    # @return [void]
    def set_aliases(aliases)
      raise TypeError, 'Aliases must be a hash' unless aliases.kind_of?(Hash)

      @aliases = AliasMap.new *self, **aliases
    end

    # Check if the provided `fallback` is valid
    #
    # @param [String, Symbol, nil] fallback
    def valid_fallback?(fallback)
      return true if fallback.nil? && allow_nil?
      return true if include? fallback

      false
    end

    # Set the default fallback value.
    #
    # @param [String, Symbol, nil] fallback
    # @return [void]
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

    # Raised when attempting to use an invalid
    # value as a fallback
    class InvalidFallback < ArgumentError
    end

    # Raised when trying to set an already-defined
    # member as an alias
    class MemberAsAliasError < ArgumentError
    end

    # Raised when trying to set an invalid alias
    # target
    class InvalidAliasTargetError < ArgumentError
    end

    # An indifferent, read-only hash-like object
    # for mapping aliases.
    #
    # @api private
    class AliasMap
      # @param [<Dux::IndifferentString>] targets
      # @param [{Symbol => String, Symbol}] aliases
      def initialize(*targets, **aliases)
        @mapping = aliases.each_with_object({}) do |(aliaz, target), mapping|
          aliaz   = indifferentize(aliaz)
          target  = indifferentize(target)

          if targets.include? aliaz
            raise MemberAsAliasError, "alias `#{aliaz}` is already an enum member"
          end

          unless targets.include? target
            raise InvalidAliasTargetError, "alias target `#{target}` is not an enum member"
          end

          mapping[aliaz] = target
        end.freeze

        @aliases = @mapping.keys.freeze

        freeze
      end

      def alias?(aliaz)
        @aliases.include? aliaz
      end

      alias_method :key?, :alias?

      # @param [String, Symbol] aliaz
      # @return [Dux::IndifferentString]
      def fetch(aliaz)
        @mapping[indifferentize(aliaz)]
      end

      alias_method :[], :fetch

      # @return [Hash]
      def to_h
        # :nocov:
        @mapping.to_h
        # :nocov:
      end

      private

      # Check if the value is acceptable for mapping.
      def acceptable?(value)
        value.kind_of?(String) || value.kind_of?(Symbol) || value.kind_of?(Dux::IndifferentString)
      end

      # @param [String, Symbol] value
      # @return [Dux::IndifferentString]
      def indifferentize(value)
        raise TypeError, "invalid aliaz or target: #{value.inspect}" unless acceptable?(value)

        Dux::IndifferentString.new value
      end
    end
  end

  class << self
    # @!group DSL

    # Create {Dux::Enum an enum} with the provided options.
    #
    # @see Dux::Enum#initialize
    # @return [Dux::Enum]
    def enum(*values, **options)
      Dux::Enum.new(*values, **options)
    end

    # @!endgroup
  end
end
