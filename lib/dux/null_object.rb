module Dux
  # Null objects that can be used for smarter
  # argument building.
  #
  # @example Usage
  #   module Foo
  #     class Bar
  #       NULL = Dux.null 'Foo::Bar::NULL'
  #
  #       # Making it private is not required,
  #       # but recommended if it is something
  #       # that should only be available
  #       # internally.
  #       private_constant :NULL
  #
  #       def initialize(some_option: NULL)
  #         if some_option == NULL
  #           # Do some default logic
  #         else
  #           @some_option = some_option
  #         end
  #       end
  #     end
  #   end
  class NullObject
    include Dux::InspectID

    # @!attribute [r] name
    # The name of this null object,
    # for self-documenting / introspection.
    #
    # In practice, this should be the object path,
    # e.g. `Foo::Bar::NULL`
    # @return [String]
    attr_reader :name

    # @!attribute [r] purpose
    # A purpose or description of this object,
    # for self-documenting / introspection.
    # @return [String]
    attr_reader :purpose

    # @param [String] name
    # @param [String] purpose
    def initialize(name = nil, purpose: 'a null object')
      @name     = name || default_name
      @purpose  = purpose

      freeze
    end

    private

    # Generates a default name for this object.
    #
    # @return [String]
    def default_name
      "Dux::NullObject(#{inspect_id(self)})"
    end
  end

  class << self
    # @!group DSL

    # Create {Dux::NullObject a null object} with the provided options.
    #
    # @see Dux::NullObject#initialize
    # @return [Dux::NullObject]
    def null_object(name = nil, **options)
      Dux::NullObject.new(name, **options)
    end

    alias_method :null, :null_object

    # @!endgroup DSL
  end
end
