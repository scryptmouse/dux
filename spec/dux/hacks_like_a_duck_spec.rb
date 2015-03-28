describe Dux::HacksLikeADuck do
  include_context 'test objects and methods'

  before do
    Dux.array_shorthand!
    Dux.symbol_shorthand!
    Dux.string_shorthand!
  end

  it 'adds Array#~' do
    expect([]).to respond_to :~
  end

  it 'adds String#~' do
    expect("foo").to respond_to :~
  end

  it 'adds Symbol#~' do
    expect(:foo).to respond_to :~
  end

  flock_test_for 'Array#~', all: true do
    ~test_methods
  end

  inline_quack_test_for Symbol, duck_method: :~
  inline_quack_test_for String, duck_method: :~
end
