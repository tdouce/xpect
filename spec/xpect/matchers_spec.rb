require 'xpect/matchers'

RSpec.describe Xpect::Matchers do
  let(:truthy_values) { ["truthy", ["truthy"], {"truthy" => "the"}, 9, 9.15] }
  let(:falsy_values) { [nil, [], "", {}] }

  describe '.anything' do
    context 'when truthy' do
      it 'should return true' do
        truthy_values.each do |val|
          expect(
            described_class.anything.call(val)
          ).to eq true
        end
      end
    end

    context 'when falsy' do
      it 'should return true' do
        falsy_values.each do |val|
          expect(
            described_class.anything.call(val)
          ).to eq true
        end
      end
    end
  end

  describe '.nil' do
    context 'when nil' do
      it 'should return true' do
        expect(
          described_class.nil.call(nil)
        ).to eq true
      end
    end

    context 'when not nil' do
      it 'should raise FailedSpec' do
        expect {
          described_class.nil.call("truthy")
        }.to raise_error(Xpect::FailedSpec, /'truthy' is not nil/)
      end
    end
  end

  describe '.falsy' do
    context 'when truthy' do
      it 'should raise FailedSpec' do
        expect {
          described_class.falsy.call("truthy")
        }.to raise_error(Xpect::FailedSpec, /'truthy' is not falsy/)
      end
    end

    context 'when falsy' do
      it 'should return true' do
        falsy_values.each do |val|
          expect(
            described_class.falsy.call(val)
          ).to eq true
        end
      end
    end
  end

  describe '.truthy' do
    context 'when truthy' do
      it 'should return true' do
        truthy_values.each do |val|
          expect(
            described_class.truthy.call(val)
          ).to eq true
        end
      end
    end

    context 'when falsy' do
      it 'should raise FailedSpec' do
        falsy_values.each do |val|
          expect {
            described_class.truthy.call(val)
          }.to raise_error(Xpect::FailedSpec, "'#{ val }' is not truthy.")
        end
      end
    end
  end
end