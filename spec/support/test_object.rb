class Dux::TestObject
  attr_reader :method_names

  def initialize(*method_names)
    method_names.flatten!

    @method_names = method_names

    method_names.each do |method_name|
      define_singleton_method method_name do
        true
      end
    end
  end

  def inspect
    "<Dux::TestObject(#{method_names_as_string})>"
  end

  def quack
    true
  end

  private
  def method_names_as_string
    method_names.map(&:inspect).join(', ')
  end

  def secret_quack
    true
  end
end
