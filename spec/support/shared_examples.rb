RSpec.shared_context 'test objects and methods' do
  let(:test_methods) { %i[foo bar baz quux] }
  let(:test_object_with_all_methods) { Dux::TestObject.new(test_methods) }
  let(:blank_test_object) { Dux::TestObject.new }
  let(:single_test_objects) { test_methods.map { |m| Dux::TestObject.new(m) } }
end

RSpec.shared_examples 'a success' do
  it 'succeeds' do
    is_expected.to be true
  end
end

RSpec.shared_examples 'a failure' do
  it 'fails' do
    is_expected.to be false
  end
end
