module Dux
  # Simplify the creation of comparable objects by specifying
  # a list of attributes (with optional ordering) that
  # determines how they should be compared, without having
  # to define a spaceship (`<=>`) operator in the given class.
  class Comparable < Module
    # Valid orders for sorting
    ORDERS = Dux.enum(:asc, :desc, aliases: { ascending: :asc, descending: :desc })

    private_constant :ORDERS

    # Checks if an attribute argument is a valid tuple
    ATTRIBUTE_TUPLE = Dux.yard('(Symbol, Symbol)')

    private_constant :ATTRIBUTE_TUPLE

    # @param [<Symbol, (Symbol, Symbol)>] attributes
    # @param [Boolean, String] type_guard
    # @param [:asc, :desc, :ascending, :descending] sort_order
    def initialize(*attributes, sort_order: :asc, type_guard: true, **options)
      @default_sort_order = validate_order sort_order

      @type_guard = validate_type_guard type_guard

      @attributes = parse_attributes(attributes)

      if @attributes.one?
        @default_sort_order = @attributes.first.order
      end

      include ::Comparable

      class_eval spaceship_method, __FILE__, __LINE__ + 1
    end

    # Display the attributes used to compare for clarity
    # in class ancestor listings.
    #
    # @return [String]
    def inspect
      attribute_list = @attributes.map do |attribute|
        attribute.to_inspect(many: many?, default: @default_sort_order)
      end.join(', ')

      if many?
        attribute_list = "[#{attribute_list}]"

        attribute_list << ", default_order: #{@default_sort_order.to_s.upcase}"
      end

      "Dux::Comparable(#{attribute_list})"
    end

    # Determine if we are operating on many attributes
    #
    # Boolean complement of {#single?}.
    def many?
      @attributes.length > 1
    end

    # Determine if we are operating on a single attribute
    #
    # Boolean complement of {#many?}.
    def single?
      @attributes.one?
    end

    # Determine if we have a type guard that requires
    # another of the same class.
    def same_type_guard?
      @type_guard == true
    end

    # Determine if
    def specific_type_guard?
      @type_guard.kind_of?(String) && Dux.presentish?(@type_guard)
    end

    # Determine if we have any kind of type guard.
    #
    # @see [#same_type_guard?]
    # @see [#specific_type_guard?]
    def type_guard?
      same_type_guard? || specific_type_guard?
    end

    # @api private
    # @return [String]
    def spaceship_method
      @spaceship_method ||= build_spaceship_method
    end

    private

    # Generates the spaceship method body.
    #
    # @return [String]
    def build_spaceship_method
      ''.tap do |body|

        body << <<-RUBY
          def <=>(other)
        RUBY

        if type_guard?
          body << <<-RUBY
              unless other.kind_of?(#{type_guard_value})
                raise TypeError, "\#{other.inspect} must be kind of \#{#{type_guard_value}}"
              end
          RUBY
        end

        body << <<-RUBY
            #{join_attributes}
        RUBY

        body << <<-RUBY
          end
        RUBY
      end
    end

    # Join the attributes to be checked in {#build_spaceship_method}
    #
    # @see [Dux::Enum::Attribute#to_comparison]
    # @return [String]
    def join_attributes
      @attributes.map do |attribute|
        attribute.to_comparison(wrap: @attributes.length > 1)
      end.join('.nonzero? || ')
    end

    # Provides the value for type guards used by {#build_spaceship_method}
    # @return [String]
    def type_guard_value
      raise 'Cannot get value for non-type guard' unless type_guard?

      if same_type_guard?
        'self.class'
      elsif specific_type_guard?
        @type_guard
      end
    end

    # @param [<Symbol, (Symbol, Symbol)>] attributes
    # @return [<Dux::Enum::Attribute>]
    def parse_attributes(attributes)
      raise ArgumentError, "Must provide at least one attribute" if attributes.empty?

      attributes.map do |attribute|
        case attribute
        when Symbol, String
          Attribute.new(attribute, @default_sort_order)
        when ATTRIBUTE_TUPLE
          Attribute.new(attribute[0], validate_order(attribute[1]))
        else
          raise ArgumentError, "Don't know what to do with #{attribute.inspect}"
        end
      end.freeze
    end

    # @param [Symbol, String] sort_order
    # @raise [ArgumentError] when given an improper sort order
    # @return [Symbol]
    def validate_order(sort_order)
      ORDERS[sort_order]
    rescue Dux::Enum::NotFound => e
      raise ArgumentError, "invalid sort order: #{sort_order.inspect}"
    end

    # @param [Boolean, String, Symbol] type_guard
    # @raise [TypeError] when given an improper type guard
    # @return [Boolean, String, Symbol]
    def validate_type_guard(type_guard)
      case type_guard
      when true, false, nil then type_guard
      when Class, Module
        type_guard.name
      when String, Symbol, Dux::IndifferentString
        type_guard.to_s
      else
        raise TypeError, "Don't know what to do with type guard: #{type_guard.inspect}"
      end
    end

    # Attribute definition with sort ordering.
    #
    # @api private
    class Attribute < Struct.new(:name, :order)
      # Check if the {#order} is ascending
      def ascending?
        order == :asc
      end

      # Check if the {#order} is descending
      def descending?
        order == :desc
      end

      # @param [Boolean] many
      # @param [:asc, :desc, nil] default
      # @api private
      # @return [String]
      def to_inspect(many: false, default: nil)
        ":#{name}".tap do |s|
          s << " #{order.to_s.upcase}" unless many && order == default
        end
      end

      # Generate the comparison expression used to compare
      # this attribute against another.
      #
      # @param [Boolean] wrap if the expression should be wrapped
      #   in parentheses.
      # @return [String]
      def to_comparison(wrap: false)
        if ascending?
          "self.#{name} <=> other.#{name}"
        elsif descending?
          "other.#{name} <=> self.#{name}"
        end.tap do |expression|
          return "(#{expression})" if wrap
        end
      end
    end
  end

  class << self
    # @!group DSL

    # Create {Dux::Comparable a comparable module} with the provided options.
    #
    # @see [Dux::Comparable#initialize]
    # @return [Dux::Comparable]
    def comparable(*attributes, **options)
      Dux::Comparable.new(*attributes, **options)
    end

    # @!endgroup
  end
end
