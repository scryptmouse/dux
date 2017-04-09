RSpec.describe 'Dux.inherits' do
  let(:mod) { Module.new }
  let(:prepended_mod) { Module.new }
  let(:other_klass) { Class.new }
  let(:other_mod) { Module.new }
  let(:superklass) { Class.new }
  let(:klass) { Class.new(superklass) }

  before(:each) do
    klass.include mod
    klass.prepend prepended_mod
  end

  it 'raises an error if you provide a non-module/class' do
    expect do
      Dux.inherits :wrong
    end.to raise_error TypeError
  end

  it 'can test for module inclusion' do
    expect(Dux.inherits(mod)).to be === klass
    expect(Dux.includes(other_mod)).not_to be === klass
  end

  it 'works with prepended modules' do
    expect(Dux.prepends(prepended_mod)).to be === klass
  end

  it 'can test for class inheritance' do
    expect(Dux.inherits(superklass)).to be === klass
    expect(Dux.inherits(klass)).not_to be === klass
    expect(Dux.inherits(other_klass)).not_to be === klass
  end

  context 'when include_self: true' do
    it 'can test if the class is also itself' do
      expect(Dux.inherits(superklass, include_self: true)).to be === superklass
      expect(Dux.inherits(klass, include_self: true)).to be === klass
      expect(Dux.inherits(other_klass)).not_to be === klass
    end
  end
end
