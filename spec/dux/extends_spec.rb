RSpec.describe 'Dux.extends' do
  let(:mod) { Module.new }
  let(:klass) { Class.new }

  let(:other_mod) { Module.new }
  let(:other_klass) { Class.new }

  before(:each) do
    klass.extend mod
  end

  it 'can test for extension' do
    expect(Dux.extends(mod)).to be === klass
    expect(Dux.extends(other_mod)).not_to be === klass
    expect(Dux.extends(mod)).not_to be === other_klass
  end

  it 'raises an error when provided with a non-module' do
    expect do
      Dux.extends :wrong
    end.to raise_error TypeError
  end
end
