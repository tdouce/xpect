require 'xpect/pred'

RSpec.describe Xpect::Pred do
  let(:predicate) { lambda {|v| v == 'here'} }

  describe '#conform!' do
    context 'when pred is truthy' do
      it 'should return the value' do
        pred = described_class.new(pred: predicate)

        expect(
          pred.conform!(value: 'here')
        ).to eq 'here'
      end
    end

    context 'when pred is falsy' do
      it 'should return the value' do
        pred = described_class.new(pred: predicate)

        expect {
          pred.conform!(value: 'there', path: ['my-key'])
        }.to raise_error(Xpect::FailedSpec, "'there' does not meet spec for '[\"my-key\"]'")
      end

      context 'when value is nil' do
        it 'should raise a Failed Spec' do
          pred = described_class.new(pred: predicate)

          expect {
            pred.conform!(value: nil, path: ['my-key'])
          }.to raise_error(Xpect::FailedSpec, "the value at path '[\"my-key\"]' is missing")
        end
      end
    end

    context 'with options' do
      context 'when value is not present' do
        context 'when default is supplied' do
          it 'should return the default' do
            pred = described_class.new(
              pred: predicate,
              default: 'my-default'
            )

            expect(
              pred.conform!(value: nil)
            ).to eq 'my-default'
          end
        end

        context 'when default is not supplied' do
          it 'should raise a FailedSpec' do
            pred = described_class.new(
              pred: predicate,
            )

            expect {
              pred.conform!(value: nil)
            }.to raise_error(Xpect::FailedSpec, "the value at path '' is missing")
          end
        end
      end

      context 'when value is present' do
        context 'when default is supplied' do
          context 'when pred is truthy' do
            it 'should return the value' do
              pred = described_class.new(
                pred: predicate,
                default: 'my-default'
              )

              expect(
                pred.conform!(value: 'here')
              ).to eq 'here'
            end
          end

          context 'when pred is falsy' do
            context 'when path is supplied' do
              it 'should raise FailedSpec' do
                pred = described_class.new(
                  pred: predicate,
                  default: 'my-default'
                )

                expect {
                  pred.conform!(value: 'there', path: 'my-path')
                }.to raise_error(Xpect::FailedSpec, "'there' does not meet spec for 'my-path'")
              end
            end

            it 'should raise FailedSpec' do
              pred = described_class.new(
                pred: predicate,
                default: 'my-default'
              )

              expect {
                pred.conform!(value: 'there')
              }.to raise_error(Xpect::FailedSpec, "'there' does not meet spec for ''")
            end

            context 'when error_msg is supplied' do
              context 'when path is suplied' do
                it 'should raise FailedSpec with error_msg as part of the error message' do
                  pred = described_class.new(
                    pred: predicate,
                    error_msg: 'my-error-msg'
                  )

                  expect {
                    pred.conform!(value: 'there', path: 'my-path')
                  }.to raise_error(Xpect::FailedSpec, "'there' does not meet spec for 'my-path': 'my-error-msg'")
                end
              end

              it 'should raise FailedSpec with error_msg as part of the error message' do
                pred = described_class.new(
                  pred: predicate,
                  error_msg: 'my-error-msg'
                )

                expect {
                  pred.conform!(value: 'there')
                }.to raise_error(Xpect::FailedSpec, "'there' does not meet spec for '': 'my-error-msg'")
              end

              context 'when default is supplied' do
                it 'should raise FailedSpec with error_msg as part of the error message' do
                  pred = described_class.new(
                    pred: predicate,
                    default: 'my-default',
                    error_msg: 'my-error-msg'

                  )

                  expect {
                    pred.conform!(value: 'there')
                  }.to raise_error(Xpect::FailedSpec, "'there' does not meet spec for '': 'my-error-msg'")
                end
              end
            end
          end
        end
      end
    end
  end
end