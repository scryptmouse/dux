module QuackTestHelper
  # @param [String] description
  # @param [Boolean] test_include_all whether the method should test acceptance of protected methods
  # @param [#call] with
  def quack_test_for(description, with:, test_include_all: true)
    raise ArgumentError, "must provide using" unless with.respond_to? :call

    describe "#{description} quack tests" do
      let(:duck_method) { with }

      include_examples 'basic quack tests'

      if test_include_all
        include_examples 'advanced protected quack tests'
      else
        include_examples 'simple protected quack tests'
      end
    end
  end

  # @param [String, Class] description
  # @param [Symbol] coerce method used to convert a provided method name
  # @param [Symbol] duck_method the method used to generate a duck-proc
  # @param [Boolean] test_include_all
  def inline_quack_test_for(description, mod: described_class, coerce: nil, duck_method: :duckify, test_include_all: nil)
    if description.is_a?(Class)
      klass = description

      description = "#{klass}##{duck_method}"

      match_klass = ->(kls) { ->(other) { kls == other } }

      coerce = case klass
               when match_klass[String] then :to_s
               when match_klass[Symbol] then :to_sym
               end
    end

    test_include_all = mod.instance_method(duck_method).arity.nonzero? if test_include_all.nil?

    raise ArgumentError, ":coerce not provided and cannot be derived" if coerce.nil?

    duck = wrap_duck_method coerce, duck_method: duck_method, test_include_all: test_include_all

    quack_test_for description, with: duck, test_include_all: test_include_all
  end

  protected
  # @param [Symbol] coercer something like `to_s` or `to_sym`
  # @return [Proc]
  def wrap_duck_method(coercer, duck_method: :duckify, test_include_all: true)
    if test_include_all
      ->(m,include_all:false) { m.__send__(coercer).__send__(duck_method, include_all: include_all) }
    else
      ->(m) { m.__send__(coercer).__send__(duck_method) }
    end
  end
end

RSpec.configure do |c|
  c.extend QuackTestHelper
end

RSpec.shared_context 'quack test context' do
  include_context 'test objects and methods'

  let(:public_method) { :quack }
  let(:secret_method) { :secret_quack }
  let(:unknown_method) { :moo }
end

RSpec.shared_examples 'basic quack tests' do
  include_context 'quack test context'

  context 'against a public method' do
    subject { duck_method.call public_method }

    it { is_expected.to be_a_lambda }

    it { is_expected.to accept blank_test_object }
  end

  context 'against an undefined method' do
    subject { duck_method.call unknown_method }

    it { is_expected.to_not accept blank_test_object }
  end
end

RSpec.shared_examples 'advanced protected quack tests' do
  include_context 'quack test context'

  context 'against a protected method' do
    let(:secret_duck_method) do
      ->(include_all: false) { duck_method.call(secret_method, include_all: include_all) }
    end

    context 'when include_all is true' do
      subject { secret_duck_method.call include_all: true }

      it 'accepts protected methods' do
        is_expected.to accept blank_test_object
      end
    end

    context 'when include_all is false' do
      subject { secret_duck_method.call include_all: false }

      it 'ignores protected methods' do
        is_expected.to_not accept blank_test_object
      end
    end
  end
end

RSpec.shared_examples 'simple protected quack tests' do
  include_context 'quack test context'

  context 'against a protected method' do
    subject { duck_method.call secret_method }

    it { is_expected.to_not accept blank_test_object }
  end
end
