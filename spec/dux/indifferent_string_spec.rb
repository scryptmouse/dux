RSpec.describe Dux::IndifferentString do
  def self.can_create!(varname, label = nil, &additional_tests)
    label ||= varname.to_s.gsub('_', ' ')

    context "with #{label}" do
      subject { described_class.new __send__(varname) }

      it "works" do
        expect do
          subject
        end.not_to raise_error

        is_expected.to be == a_string
        is_expected.to be == a_symbol

        is_expected.to be === a_string
        is_expected.to be === a_symbol

        instance_eval(&additional_tests) if block_given?
      end
    end
  end

  let(:a_string)  { 'foo' }
  let(:a_symbol)  { :foo  }
  let(:implicit_string) { double('implicit', to_str: a_string) }
  let(:acts_like_string) do
    double('stringish', :acts_like? => false, to_s: a_string).tap do |val|
      allow(val).to receive(:acts_like?).with(:string).and_return(true)
    end
  end

  can_create! :a_string

  can_create! :a_symbol

  can_create! :implicit_string, 'something that implicitly converts to string'

  can_create! :acts_like_string, 'something that #acts_like?(:string)' do
    expect(acts_like_string).to have_received(:acts_like?).with(:string).once
  end

  context 'with something that is not stringish at all' do
    it 'does not work' do
      expect do
        described_class.new []
      end.to raise_error TypeError
    end
  end
end
