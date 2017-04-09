RSpec.describe 'Dux.yard' do
  def expect_yard(pattern, value)
    expect(Dux.yard(pattern).(value))
  end

  specify { expect_yard('(Symbol, Symbol)', %i[foo bar]).to eq true }
  specify { expect_yard('String', 'foo').to eq true }
  specify { expect_yard('{ Symbol => <String, Symbol> }', foo: [:bar, 'baz']).to eq true }
end
