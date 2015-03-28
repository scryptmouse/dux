RSpec::Matchers.define :accept do |expected|
  match do |actual|
    actual === expected
  end
end
