RSpec.describe Dux::Duckify do
  before(:all) do
    Dux.extend_strings_and_symbols!
  end

  inline_quack_test_for String
  inline_quack_test_for Symbol
end
