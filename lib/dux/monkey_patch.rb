module Dux
  class << self
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

  end
end
