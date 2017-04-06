RSpec.describe Dux::InspectID do
  it 'matches the expected pattern' do
    expect(Dux.inspect_id(Dux)).to match /\A0x[0-9a-f]{14}\z/i
  end
end
