describe Dux::FlockMethods do
  include_context 'test objects and methods'

  before do
    Dux.add_flock_methods!
  end

  Dux::FLOCK_TYPES.each do |type|
    array_flock_test type
  end
end
