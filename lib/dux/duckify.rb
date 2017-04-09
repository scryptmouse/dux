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
      Dux[for_duckify, include_all: include_all]
    end
  end
end
