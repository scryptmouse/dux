module Dux
  class IndifferentString < DelegateClass(String)
    def initialize(stringish)
      stringified =
        case stringish
        when String then stringish
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

    def ==(other)
      if other.kind_of?(Symbol)
        self == other.to_s
      else
        super
      end
    end

    alias_method :eql?, :==

    def ===(other)
      if other.kind_of?(Symbol)
        self == other.to_s
      else
        super
      end
    end
  end
end
