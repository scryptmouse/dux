describe Dux do
  include_context 'test objects and methods'

  quack_test_for '#dux', with: Dux.method(:dux)
  quack_test_for '.[]', with: Dux.method(:[])

  dux_flock_test :all
  dux_flock_test :any
  dux_flock_test :none
end
