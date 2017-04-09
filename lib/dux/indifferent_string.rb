module Dux
  # A string value that is programmatically equivalent to its symbol representation.
  class IndifferentString < DelegateClass(String)
    # @param [String, Symbol, Dux::IndifferentString, #to_str, #acts_like_string?] stringish
    def initialize(stringish)
      stringified =
        case stringish
        when String, Dux::IndifferentString then stringish
        when Symbol then stringish.to_s
        when Dux[:to_str] then stringish.to_str
        else
          if Dux.attempt(stringish, :acts_like?, :string)
            stringish.to_s
          else
            raise TypeError, "Not a string or symbol: #{stringish}"
          end
        end

      super(stringified)
    end

    # Test basic equality.
    #
    # @param [String, Symbol] other
    def ==(other)
      if other.kind_of?(Symbol)
        self == other.to_s
      else
        super
      end
    end

    alias_method :eql?, :==

    # Test case equality
    #
    # @param [String, Symbol, Regexp] other
    def ===(other)
      if other.kind_of?(Symbol)
        self == other.to_s
      else
        super
      end
    end
  end
end
