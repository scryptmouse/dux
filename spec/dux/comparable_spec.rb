class ValueWrapper < Struct.new(:value)
end

class DoubleValueWrapper < Struct.new(:value_1, :value_2)
end

RSpec.describe Dux::Comparable do
  describe 'Dux.comparable' do
    it 'creates a module' do
      expect(Dux.comparable(:foo)).to be_a_kind_of described_class
    end
  end

  it 'is inspectable' do
    expect do
      Dux.comparable(:foo, [:bar, :desc]).inspect
    end.not_to raise_error
  end

  context 'when creating the module' do
    it 'raises an error with invalid attribute names' do
      expect do
        described_class.new 123
      end.to raise_error ArgumentError
    end

    it 'raises an error with invalid sort order' do
      expect do
        described_class.new :foo, sort_order: :wrong
      end.to raise_error ArgumentError
    end

    it 'is single? with a single attribute' do
      expect(described_class.new(:foo)).to be_single
    end

    it 'is many? with many attributes' do
      expect(described_class.new(:foo, :bar)).to be_many
    end
  end

  describe 'type guards' do
    it 'guards type by default' do
      mod = described_class.new :foo

      expect(mod).to be_same_type_guard
    end

    it 'allows passing a symbolized class name as a type guard' do
      mod = described_class.new(:foo, type_guard: :ValueWrapper)

      expect(mod).to be_specific_type_guard
    end

    it 'allows passing a class or module as a type guard' do
      mod = described_class.new(:foo, type_guard: ValueWrapper)

      expect(mod).to be_specific_type_guard
    end

    it 'does not support weird type guards' do
      expect do
        described_class.new(:foo, type_guard: [:array, :of, :things])
      end.to raise_error TypeError
    end
  end

  describe 'implementations' do
    let(:base_klass) { ValueWrapper }

    def create_class_with_comparable(*comparable_args, **comparable_options)
      comparable_args = base_klass.members if comparable_args.empty?

      Class.new(base_klass) do
        include Dux.comparable(*comparable_args, **comparable_options)
      end
    end

    context 'when comparing between single values' do
      let(:klass) { create_class_with_comparable }

      let(:first)   { klass.new 1 }
      let(:second)  { klass.new 2 }

      it 'sorts correctly' do
        expect([second, first].sort).to eq [first, second]
      end

      context 'with descending sort order' do
        let(:klass) { create_class_with_comparable sort_order: :desc }

        it 'sorts correctly' do
          expect([first, second].sort).to eq [second, first]
        end
      end
    end

    context 'when comparing between two values' do
      let(:base_klass) { DoubleValueWrapper }

      let(:klass) { create_class_with_comparable }

      let(:ba) { klass.new ?b, ?a }
      let(:bb) { klass.new ?b, ?b }
      let(:ca) { klass.new ?c, ?a }
      let(:cb) { klass.new ?c, ?b }

      it 'sorts correctly' do
        expect([cb, bb, ca, ba].sort).to eq [ba, bb, ca, cb]
      end

      context 'with (value_1 DESC, value_2 ASC)' do
        let(:klass) { create_class_with_comparable [:value_1, :desc], :value_2 }

        it 'sorts correctly' do
          expect([cb, bb, ca, ba].sort).to eq [ca, cb, ba, bb]
        end
      end
    end
  end
end
