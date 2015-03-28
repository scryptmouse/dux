module FlockTestHelper
  CONTEXTS = {
    all: 'when all methods match',
    one: 'when only one method matches',
    none: 'when no methods match'
  }

  RESULTS = %w[success failure].zip([true, false])

  def array_flock_test(type, include_all: false, &block)
    description = "Array#duckify(type: :#{type})"

    description += " (default)" if type == :all

    test_all = type == :all || type == :any
    test_one = type == :any
    test_none = type == :none

    flock_test_for description, all: test_all, none: test_none, one: test_one do
      ( block_given? ? yield : test_methods ).duckify(type: type, include_all: include_all)
    end
  end

  def dux_flock_test(method)
    test_all  = method == :all || method == :any
    test_one  = method == :any
    test_none = method == :none

    flock_test_for ".#{method}", all: test_all, none: test_none, one: test_one do
      Dux.__send__(method, test_methods)
    end
  end

  def flock_test_for(description, all: false, none: false, one: false, &block)
    describe "#{description} flock tests" do
      let(:duck_with_all_methods, &block)

      it_behaves_like flock_example_group :all, all
      it_behaves_like flock_example_group :none, none
      it_behaves_like flock_example_group :one, one
    end
  end

  def each_context(&block)
    CONTEXTS.values.each do |ctx|
      yield ctx
    end
  end

  module_function :each_context

  def each_result(&block)
    RESULTS.each do |result|
      yield result
    end
  end

  module_function :each_result

  protected
  # @param [Symbol] name
  # @param [Boolean] expected_result
  # @return [String]
  def flock_example_group(name, expected_result)
    "%s %s" % [flock_result(expected_result), CONTEXTS.fetch(name)]
  end

  # @param [Boolean] expected_result
  # @return [String]
  def flock_result(expected_result)
    expected_result ? 'a success' : 'a failure'
  end
end

RSpec.configure do |c|
  c.extend FlockTestHelper
end

RSpec.shared_context 'when all methods match' do |success|
  subject do
    duck_with_all_methods.call test_object_with_all_methods
  end

  include_examples success ? 'a success' : 'a failure'
end

RSpec.shared_context 'when no methods match' do |success|
  subject do
    duck_with_all_methods.call blank_test_object
  end

  include_examples success ? 'a success' : 'a failure'
end

RSpec.shared_context 'when only one method matches' do |success|
  subject do
    single_test_objects.all?(&duck_with_all_methods)
  end

  include_examples success ? 'a success' : 'a failure'
end

FlockTestHelper.each_result do |(str, value)|
  FlockTestHelper.each_context do |ctx|
    RSpec.shared_examples "a #{str} #{ctx}" do
      include_context ctx, value
    end
  end
end
