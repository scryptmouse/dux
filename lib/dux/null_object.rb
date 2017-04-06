module Dux
  class NullObject
    include Dux::InspectID

    attr_reader :name
    attr_reader :purpose

    # @param [String] name
    # @param [String] purpose
    def initialize(name, purpose: 'a null object')
      @name     = name
      @purpose  = purpose
    end

    private
    def default_name
      
    end
  end

  class << self
    # @param (@see Dux::NullObject#initialize)
    # @return [Dux::NullObject]
    def null_object(name, **options)
      Dux::NullObject.new(name, **options)
    end

    alias_method :null, :null_object
  end
end
