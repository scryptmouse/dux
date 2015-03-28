module Dux
  # Adds a fluent {#duckify} method to classes that include / prepend.
  #
  # Non-stringish / symbol classes should override {#for_duckify} to
  # return a string or symbol.
  module Duckify
    # @return [self, String, Symbol]
    def for_duckify
      self
    end

    # @param [Boolean] include_all
    # @return [Proc]
    def duckify(include_all: false)
      dux for_duckify, include_all: include_all
    end

    class << self
      # @api private
      # @param [Class] base
      # @return [void]
      def included(base)
        base.__send__ :include, Dux
      end

      alias_method :prepended, :included
      alias_method :extended, :included
    end
  end
end
