module Dux
  # Methods for generating "interface" checks against an array of symbols
  FLOCK_TYPES = Dux.enum :all, :any, :none

  class << self
    # @!group Predicates

    # Create a predicate that checks if the provided object
    # responds to the `symbol`.
    #
    # @param [Symbol] symbol
    # @param [Boolean] include_all
    # @return [Proc]
    def [](symbol, include_all: false)
      ->(obj) { obj.respond_to? symbol, include_all }
    end

    alias_method :predicate, :[]
    alias_method :dux, :[]

    # Create a predicate that checks if the provided `Class` or `Module`
    # inherits from a given class or module.
    #
    # @param [Class, Module] parent
    # @param [Boolean] include_self
    # @raise [TypeError] requires a class or module to serve as parent
    # @return [Proc]
    def inherits(parent, include_self: false)
      raise TypeError, "Must be a class or module to check inheritance" unless inheritable?(parent)

      if include_self
        ->(klass) { Dux.inheritable?(klass) && klass <= parent }
      else
        ->(klass) { Dux.inheritable?(klass) && klass < parent }
      end
    end

    alias_method :includes, :inherits
    alias_method :prepends, :inherits

    # Create a predicate that checks if the provided `Class` or `Module`
    # extends a given `parent` module.
    #
    # @param [Module] parent
    # @raise [TypeError] requires a module to check extension
    # @return [Proc]
    def extends(parent)
      raise TypeError, "Must be a module to check if something extends it" unless parent.kind_of?(Module)

      ->(klass) { Dux.inheritable?(klass) && klass.singleton_class < parent }
    end

    # Create a predicate that checks against a specific YARD type description.
    #
    # @note Some limitations apply because of the underlying gem, e.g.
    #   symbol / string literals are not matched and will raise an error
    # @see https://github.com/pd/yard_types the gem used for parsing types
    # @raise [SyntaxError] when `YardTypes` fails to parse.
    # @param [String] pattern
    # @return [Proc]
    def yard(pattern)
      type = YardTypes.parse pattern

      ->(value) { !type.check(value).nil? }
    end

    # Check if the provided thing is a class or a module.
    #
    # @param [Class, Module] klass_or_module
    # @api private
    def inheritable?(klass_or_module)
      klass_or_module.kind_of?(Class) || klass_or_module.kind_of?(Module)
    end

    # Creates a lambda that describes a restrictive interface,
    # wherein the provided object must `respond_to?` *all* of
    # the methods.
    #
    # @param [<Symbol, String>] methods
    # @param [Boolean] include_all
    # @return [Proc]
    def all(*methods, include_all: false)
      ducks = flockify methods, include_all: include_all

      ->(obj) { ducks.all? { |duck| duck.call obj } }
    end

    # Creates a lambda that describes a permissive interface,
    # wherein the provided object must `respond_to?` at least
    # one of the methods.
    #
    # @param [<Symbol>] methods
    # @param [Boolean] include_all
    # @return [Proc]
    def any(*methods, include_all: false)
      ducks = flockify methods, include_all: include_all

      ->(obj) { ducks.any? { |duck| duck.call obj } }
    end

    # Creates a lambda that describes a restrictive interface,
    # wherein the provided object must `respond_to?` *none* of
    # the methods.
    #
    # @param [<Symbol>] methods
    # @param [Boolean] include_all
    # @return [Proc]
    def none(*methods, include_all: false)
      ducks = flockify methods, include_all: include_all

      ->(obj) { ducks.none? { |duck| duck.call obj } }
    end

    # @param [:all, :any, :none] type
    # @param [<Symbol, String>] methods
    # @param [Boolean] include_all
    # @raise [ArgumentError] on invalid type
    # @api private
    # @return [<Proc>]
    def flock(type, *methods, include_all: false)
      type = FLOCK_TYPES.fetch(type) { raise ArgumentError, "Invalid flock type: #{type}" }

      __send__ type, methods, include_all: include_all
    end

    protected

    # @param [<Symbol>] methods
    # @param [Boolean] include_all
    # @return [<Proc>]
    def flockify(methods, include_all: false)
      methods.flatten.map do |sym|
        dux sym, include_all: include_all
      end
    end

    # @!endgroup
  end
end
