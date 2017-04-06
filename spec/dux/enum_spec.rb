RSpec.describe Dux::Enum do
  let(:values) { [:foo, :bar, :baz] }
  let(:options) { Hash.new }

  let(:enum) { described_class.new(*values, **options) }

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

  context 'when fetching' do
    context 'a valid value' do
      it 'works' do
        expect(subject.fetch(:foo)).to eq :foo
      end
    end

    context 'something invalid, with a fallback' do
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

    context 'something invalid, with a default set' do
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

    context 'something invalid' do
      it 'fails' do
        expect do
          subject.fetch(:wrong)
        end.to raise_error Dux::Enum::NotFound
      end
    end
  end
end
