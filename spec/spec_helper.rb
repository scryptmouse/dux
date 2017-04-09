require 'bundler/setup'

require 'pry'

if RUBY_PLATFORM != 'java'
  require 'simplecov'

  SimpleCov.start do
    add_filter "test_object.rb"
    add_filter "spec/support"
  end
end


require 'dux'

Dux.extend_all! experimental: true

Dir["./spec/support/**/*.rb"].sort.each { |f| require f }
