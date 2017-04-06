module Dux
  module InspectID
    # Calculates the id shown in the default
    # version of `#inspect` methods.
    #
    # @param [Object] object
    # @return [String]
    def inspect_id(object)
      "0x%0.14x" % ( object.object_id << 1 )
    end

    extend self
  end

  extend InspectID
end
