$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'simplecov'

SimpleCov.start do
  add_filter "test_object.rb"
end

require 'dux'

Dux.extend_all! experimental: true

Dir["./spec/support/**/*.rb"].sort.each { |f| require f }
