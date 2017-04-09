RSpec.describe Dux::FlockMethods do
  include_context 'test objects and methods'

  before do
    Dux.add_flock_methods!
  end

  array_flock_test :all
  array_flock_test :any
  array_flock_test :none
end
