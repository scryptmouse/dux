RSpec.describe Dux::NullObject do
  let(:name) { "foo" }
  let(:purpose) { "testing" }
  let(:instance) { described_class.new name, purpose: purpose }

  describe 'Dux.null_object' do
    it 'can be used to generate a null object' do
      expect(Dux.null_object).to be_a_kind_of described_class
    end
  end

  describe 'Dux.null' do
    it 'can be used to generate a null object' do
      expect(Dux.null).to be_a_kind_of described_class
    end
  end

  it 'has a purpose' do
    expect(instance.purpose).to eq purpose
  end

  it 'has a name' do
    expect(instance.name).to eq name
  end

  it 'has a default name if no name provided' do
    blank_instance = described_class.new

    expect(blank_instance.name).to include Dux.inspect_id(blank_instance)
  end
end
