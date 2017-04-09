RSpec.describe 'Dux::Blankness' do
  include_context 'testing blankness'

  let(:empty_object) { double('empty object', :empty? => true) }
  let(:blank_object) { double('blank object', :blank? => true) }

  context 'with values that should be blank' do
    blank_test nil
    blank_test false
    blank_test Float::NAN
    blank_test []
    blank_test [nil], 'an array with only nil'
    blank_test [' '], 'an array with an empty string'
    blank_test '', 'an empty string'
    blank_test ' ', 'a string with only whitespace'
    blank_test :'', 'an empty symbol'
    blank_test({}, 'an empty hash')

    blank_test('a blank object') { blank_object }
    blank_test('an empty object') do
      empty_object
    end
  end

  context 'with values that should be present' do
    presence_test 'a non-empty string'
    presence_test %w[an array of words]
    presence_test 1234, 'a number'
    presence_test({ foo: 'bar' }, 'a non-empty hash')
  end
end
