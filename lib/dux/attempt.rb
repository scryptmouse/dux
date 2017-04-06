module Dux
  # `Object#try` for when you don't want ActiveSupport
  module Attempt
    # @param [Object] receiver
    # @param [Symbol] method
    # @param [<Object>] args
    # @return [Object]
    # @return [nil]
    def attempt(receiver, method, *args, &block)
      receiver.public_send(method, *args, &block) if receiver.respond_to?(method)
    end

    extend self
  end

  extend Attempt
end
