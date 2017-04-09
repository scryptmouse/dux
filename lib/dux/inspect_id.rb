module Dux
  # Calculate the object's inspection id
  module InspectID
    # Calculates the id shown in the default
    # version of `#inspect` methods.
    #
    # @note This is currently limited to the implementation
    #   used in MRI. Rubinius and JRuby have their own
    #   implementations that are not currently served
    #   by this.
    # @param [Object] object
    # @return [String]
    def inspect_id(object = self)
      "0x%0.14x" % ( object.object_id << 1 )
    end

    extend self
  end

  extend InspectID
end
