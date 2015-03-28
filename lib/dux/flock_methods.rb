module Dux
  # Can be included on any Array or Array-like (implements `#to_a`)
  # to grant it a fluent method for generating duck checks.
  module FlockMethods
    # @param [:all, :any, :none] type
    # @param [Boolean] include_all
    # @return [<Proc>]
    def duckify(type: :all, include_all: false)
      Dux.flock type, to_a, include_all: include_all
    end
  end
end
