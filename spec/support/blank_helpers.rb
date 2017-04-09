module DuxTesting
  module BlankHelpers
    NOTHING = Object.new.freeze

    module SpecMethods
      def test_blankness_of(value: NOTHING, expectation:, description: nil, &block)
        label =
          if description.nil?
            unless value.equal?(NOTHING)
              "`#{value.inspect}`"
            else
              raise 'Provide a description when block is given'
            end
          else
            description.to_s
          end

        specify(label) do
          test_method(:blankish?, value: value, &block).to ( expectation ? be_truthy : be_falsey )
          test_method(:presentish?, value: value, &block).to ( expectation ? be_falsey : be_truthy )
        end
      end

      def blank_test(*args, &block)
        value, description =
          if args.length == 1 && block_given?
            [NOTHING, args[0]]
          elsif args.length == 1
            [args[0], nil]
          elsif args.length == 2
            args
          else
            raise 'invalid args'
          end

        test_blankness_of(value: value, expectation: true, description: description, &block)
      end

      def presence_test(value, description = nil, &block)
        test_blankness_of(value: value, expectation: false, description: description, &block)
      end
    end

    module ExampleMethods
      def test_method(method_name, value: NOTHING, &block)
        actual_value =
          unless value.equal?(NOTHING)
            value
          else
            raise 'Must pass a block if value unspecified' unless block_given?

            instance_eval(&block)
          end

        expect(Dux.__send__(method_name, actual_value))
      end
    end
  end
end

RSpec.shared_context 'testing blankness' do
  include DuxTesting::BlankHelpers::ExampleMethods
  extend DuxTesting::BlankHelpers::SpecMethods
end
