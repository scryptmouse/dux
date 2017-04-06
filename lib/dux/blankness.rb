module Dux
  module Blankness
    WHITESPACE_ONLY = /\A[[:space:]]+\z/

    # Check if a provided object is semantically empty.
    #
    # @param [Object] value
    def blankish?(value)
      case value
      when nil, false
        true
      when Dux[:nan?]
        true
      when String, Symbol
        value.empty? || value =~ WHITESPACE_ONLY
      when Dux[:blank?]
        value.blank?
      when Hash
        value.empty?
      when Array, Enumerable
        Dux.attempt(value, :empty?) || value.all? { |val| blankish?(val) }
      when Dux[:empty?]
        value.empty?
      else
        false
      end
    end

    # Boolean complement of {#blankish?}
    #
    # @param [Object] value
    def presentish?(value)
      !blankish?(value)
    end

    extend self
  end
end
