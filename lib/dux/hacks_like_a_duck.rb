module Dux
  # Experimental module to grant unary `~` to symbols or strings for duck-checking
  module HacksLikeADuck

    # Transform into a proc that asks its argument if it responds to `self`
    #
    # @return [Proc]
    def ~
      duckify
    end
  end
end
