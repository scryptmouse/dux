require 'dux/version'
require 'dux/duckify'
require 'dux/hacks_like_a_duck'
require 'dux/flock_methods'

# Super simple duck-type testing.
module Dux
  # Methods for generating "interface" checks against an array of symbols
  FLOCK_TYPES = %i[all any none]

  module_function

  # @param [Symbol] symbol
  # @param [Boolean] include_all
  # @return [Proc]
  def dux(symbol, include_all: false)
    ->(obj) { obj.respond_to? symbol, include_all }
  end

  class << self
    alias_method :[], :dux

    # @param [:all, :any, :none] type
    # @param [<Symbol, String>] methods
    # @param [Boolean] include_all
    # @raise [ArgumentError] on invalid type
    # @return [<Proc>]
    def flock(type, *methods, include_all: false)
      raise ArgumentError, "Invalid flock type: #{type}" unless FLOCK_TYPES.include? type

      __send__ type, methods, include_all: include_all
    end

    # Creates a lambda that describes a restrictive interface,
    # wherein the provided object must `respond_to?` *all* of
    # the methods.
    #
    # @param [<Symbol, String>] methods
    # @param [Boolean] include_all
    # @return [Proc]
    def all(*methods, include_all: false)
      ducks = flockify methods, include_all: include_all

      ->(obj) { ducks.all? { |duck| duck.call obj } }
    end

    # Creates a lambda that describes a permissive interface,
    # wherein the provided object must `respond_to?` at least
    # one of the methods.
    #
    # @param [<Symbol>] methods
    # @param [Boolean] include_all
    # @return [Proc]
    def any(*methods, include_all: false)
      ducks = flockify methods, include_all: include_all

      ->(obj) { ducks.any? { |duck| duck.call obj } }
    end

    # Creates a lambda that describes a restrictive interface,
    # wherein the provided object must `respond_to?` *none* of
    # the methods.
    #
    # @param [<Symbol>] methods
    # @param [Boolean] include_all
    # @return [Proc]
    def none(*methods, include_all: false)
      ducks = flockify methods, include_all: include_all

      ->(obj) { ducks.none? { |duck| duck.call obj } }
    end

    # @!group Core extensions

    # Enhance `Array` with {Dux::FlockMethods#duckify}
    #
    # @return [void]
    def add_flock_methods!
      Array.__send__ :prepend, Dux::FlockMethods

      return nil
    end

    # Load all `Dux` core extensions.
    #
    # @param [Boolean] experimental whether to load experimental shorthand methods
    # @return [void]
    def extend_all!(experimental: false)
      add_flock_methods!
      extend_strings_and_symbols!

      return unless experimental

      array_shorthand!
      string_shorthand!
      symbol_shorthand!
    end

    # Enhance `String` with {Dux::Duckify}
    #
    # @return [void]
    def extend_strings!
      String.__send__ :prepend, Dux::Duckify

      return nil
    end

    # Enhance `Symbol` with {Dux::Duckify}
    #
    # @return [void]
    def extend_symbols!
      Symbol.__send__ :prepend, Dux::Duckify

      return nil
    end

    # Enhance `String` and `Symbol` classes with {Dux::Duckify#duckify}
    #
    # @return [void]
    def extend_strings_and_symbols!
      extend_strings!
      extend_symbols!

      return nil
    end

    # Experimental feature to add unary `~` to `Array`s
    # for quick usage in case statements.
    #
    # @return [void]
    def array_shorthand!
      add_flock_methods!

      Array.__send__ :prepend, Dux::HacksLikeADuck

      nil
    end

    # Experimental feature to add unary `~` to `String`s
    # for quick usage in case statements.
    #
    # @return [void]
    def string_shorthand!
      extend_strings!
      String.__send__ :prepend, Dux::HacksLikeADuck

      nil
    end

    # Experimental feature to add unary `~` to `Symbol`s
    # for quick usage in case statements.
    #
    # @return [void]
    def symbol_shorthand!
      extend_symbols!

      Symbol.__send__ :prepend, Dux::HacksLikeADuck

      return nil
    end

    # @!endgroup

    protected
    # @param [<Symbol>] methods
    # @param [Boolean] include_all
    # @return [<Proc>]
    def flockify(methods, include_all: false)
      methods.flatten.map do |sym|
        dux sym, include_all: include_all
      end
    end
  end
end
