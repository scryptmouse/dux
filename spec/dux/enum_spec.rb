RSpec.describe Dux::Enum do
  let(:values) { [:foo, :bar, :baz] }
  let(:return_type) { :symbol }
  let(:options) { { return_type: return_type } }

  def build_enum(*members, **options)
    members = values if members.empty?

    described_class.new(*members, **options)
  end

  let(:enum) { build_enum **options }

  subject { enum }

  it 'can be inspected' do
    expect do
      subject.inspect
    end.to_not raise_error
  end

  it 'works with strings' do
    is_expected.to include('foo').and(include('bar')).and(include('baz'))
  end

  it 'works with symbols' do
    is_expected.to include(:foo).and(include(:bar)).and(include(:baz))
  end

  it 'can test for inclusion with case equality' do
    is_expected.to (be === :foo).and (be === 'bar')
  end

  specify 'providing no values raises an error' do
    expect do
      described_class.new
    end.to raise_error TypeError
  end

  specify 'an invalid default raises an error' do
    expect do
      described_class.new(*values, default: :wrong)
    end.to raise_error Dux::Enum::InvalidFallback
  end

  describe 'nil fallbacks' do
    let(:allow_nil) { false }
    let(:default)   { :foo  }

    let(:enum) { described_class.new(*values, allow_nil: allow_nil, default: default) }

    context 'by default' do
      it 'does not allow nil' do
        is_expected.not_to be_allow_nil
      end

      specify 'nil cannot be provided as a fetch fallback' do
        expect do
          enum.fetch :wrong, fallback: nil
        end.to raise_error Dux::Enum::InvalidFallback
      end
    end

    context 'setting a nil default fallback without explicitly allowing nil' do
      let(:default) { nil }

      it 'raises an error' do
        expect do
          enum
        end.to raise_error Dux::Enum::InvalidFallback
      end
    end

    context 'with correct nil options set' do
      let(:allow_nil) { true }
      let(:default) { nil }

      it 'returns nil on fetching an invalid value' do
        expect(subject.fetch(:wrong)).to be_nil
      end
    end
  end

  context 'when fetching' do
    context 'a valid value' do
      it 'works' do
        expect(subject.fetch(:foo)).to eq :foo
      end
    end

    context 'something invalid' do
      it 'fails' do
        expect do
          subject.fetch(:wrong)
        end.to raise_error Dux::Enum::NotFound
      end

      context 'with a fallback' do
        it 'works' do
          expect(subject.fetch(:wrong, fallback: :foo)).to eq :foo
        end

        context 'that is also wrong' do
          it 'fails' do
            expect do
              subject.fetch(:wrong, fallback: :very_wrong)
            end.to raise_error(Dux::Enum::InvalidFallback, /fallback/i)
          end
        end
      end

      context 'with a default set' do
        let(:options) { { default: :foo } }

        it 'works' do
          expect(subject.fetch(:wrong)).to eq :foo
        end

        context 'and a different fallback provided' do
          it 'works' do
            expect(subject.fetch(:wrong, fallback: :bar)).to eq :bar
          end
        end
      end

      context 'with a block' do
        it 'yields to the block in lieu of an error' do
          expect do |b|
            subject.fetch(:wrong, &b)
          end.to yield_with_args(:wrong)
        end
      end
    end

    context 'with a symbol return type' do
      let(:return_type) { :symbol }

      it 'fetches a symbol when provided a string' do
        expect(subject.fetch('foo')).to eq :foo
      end
    end

    context 'with a string return type' do
      let(:return_type) { :string }

      it 'fetches a string when provided a symbol' do
        expect(subject.fetch(:foo)).to eq 'foo'
      end
    end

    context 'with an invalid return type' do
      let(:return_type) { :wrong }

      it 'raises an error on initialization' do
        expect { subject }.to raise_error ArgumentError, /return type/
      end
    end
  end

  describe 'aliases' do
    def build_enum_with_aliases(**aliases)
      build_enum aliases: aliases
    end

    context 'with a valid alias mapping' do
      let(:alias_name) { :quux }
      let(:alias_target) { :foo }

      let(:enum) { build_enum_with_aliases alias_name => alias_target }

      it 'can check for an alias' do
        expect(subject.alias?(alias_name)).to be_truthy
        expect(subject.alias?(:wrong)).to be_falsey
      end

      it 'fetches the target value' do
        expect(subject[alias_name]).to eq subject[alias_target]
      end
    end

    specify 'defining a member as an alias raises an error' do
      expect do
        build_enum_with_aliases foo: :wrong
      end.to raise_error Dux::Enum::MemberAsAliasError
    end

    specify 'trying to set an undefined member as an alias target raises an error' do
      expect do
        build_enum_with_aliases aliaz: :wrong
      end.to raise_error Dux::Enum::InvalidAliasTargetError
    end
  end
end
