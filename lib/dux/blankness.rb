module Dux
  # `Object#blank?` and `Object#present?` replacements for when
  # working outside of ActiveSupport.
  #
  # @api private
  module Blankness
    # A string containing only whitespace (as defined by unicode).
    WHITESPACE_ONLY = /\A[[:space:]]+\z/

    private_constant :WHITESPACE_ONLY

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
  end

  extend Blankness
end
