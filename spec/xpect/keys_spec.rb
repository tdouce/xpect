require 'xpect/pred'

RSpec.describe Xpect::Keys do
  context 'required options' do
    context 'when comparing value with Pred' do
      context 'when value is equal' do
        it 'should return data with required keys' do
          keys = described_class.new(
            required: {
              my_required_key: Xpect::Pred.new(
                pred: lambda {|v| v == 'my_required_key'}
              )
            },
          )

          value = {
            my_required_key: 'my_required_key'
          }

          expect(keys.conform!(value: value)).to eq(
                                                   {
                                                     my_required_key: 'my_required_key'
                                                   }
                                                 )
        end
      end

      context 'when value is not equal' do
        it 'should raise FailedSpec' do
          keys = described_class.new(
            required: {
              my_required_key: Xpect::Pred.new(
                pred: lambda {|v| v == 'my_required_key'}
              )
            },
          )

          value = {
            my_required_key: 'not_a_match'
          }

          expect {
            keys.conform!(value: value)
          }.to raise_error(Xpect::FailedSpec, "'not_a_match' does not meet spec for '[:my_required_key]'")
        end
      end
    end

    context 'when comparing value with Hash' do
      context 'when value is equal' do
        it 'should call Xpect::Spec to recurse' do
          keys = described_class.new(
            required: {
              my_required_key: {
                level_1: 1
              }
            },
          )

          value = {
            my_required_key: {
              level_1: 1
            }
          }

          expect(Xpect::Spec).to receive(:conform!).with(
            {
              spec: {level_1: 1},
              data: {level_1: 1},
              path: [:my_required_key]
            }
          )

          keys.conform!(value: value)
        end
      end

      context 'when value is not equal' do
        it 'should call Xpect::Spec to recurse' do
          keys = described_class.new(
            required: {
              my_required_key: {
                level_1: 1
              }
            },
          )

          value = {
            my_required_key: {
              level_1: 2
            }
          }

          expect(Xpect::Spec).to receive(:conform!).with(
            {
              spec: {level_1: 1},
              data: {level_1: 2},
              path: [:my_required_key]
            }
          )

          keys.conform!(value: value)
        end
      end
    end

    context 'when comparing value with Proc' do
      context 'when value is equal' do
        it 'should return data with required keys' do
          keys = described_class.new(
            required: {
              my_required_key: lambda {|v| v == 'my_required_key'}
            },
          )

          value = {
            my_required_key: 'my_required_key'
          }

          expect(keys.conform!(value: value)).to eq(
                                                   {
                                                     my_required_key: 'my_required_key'
                                                   }
                                                 )
        end
      end

      context 'when value is not equal' do
        it 'should raise FailedSpec' do
          keys = described_class.new(
            required: {
              my_required_key: lambda {|v| v == 'my_required_key'}
            },
          )

          value = {
            my_required_key: 'not_a_match'
          }

          expect {
            keys.conform!(value: value)
          }.to raise_error(Xpect::FailedSpec, "'not_a_match' does not meet expectation at '[]'")
        end
      end
    end

    context 'when comparing value equality' do
      context 'when value is equal' do
        it 'should return data with required keys' do
          keys = described_class.new(
            required: {
              my_required_key: 'my_required_key'
            },
          )

          value = {
            my_required_key: 'my_required_key'
          }

          expect(keys.conform!(value: value)).to eq(
                                                   {
                                                     my_required_key: 'my_required_key'
                                                   }
                                                 )
        end
      end

      context 'when value is not equal' do
        it 'should raise FailedSpec' do
          keys = described_class.new(
            required: {
              my_required_key: 'my_required_key'
            },
          )

          value = {
            my_required_key: 'does not match'
          }

          expect{
            keys.conform!(value: value)
          }.to raise_error(Xpect::FailedSpec, "'does not match' is not equal to 'my_required_key' at '[]'")
        end
      end
    end
  end

  context 'optional options' do
    context 'when comparing value with Hash' do
      context 'when value is equal' do
        it 'should call Xpect::Spec to recurse' do
          keys = described_class.new(
            optional: {
              my_optional_key: {
                level_1: 1
              }
            },
          )

          value = {
            my_optional_key: {
              level_1: 1
            }
          }

          expect(Xpect::Spec).to receive(:conform!).with(
            {
              spec: {level_1: 1},
              data: {level_1: 1},
              path: [:my_optional_key]
            }
          )

          keys.conform!(value: value)
        end
      end

      context 'when value is not equal' do
        it 'should call Xpect::Spec to recurse' do
          keys = described_class.new(
            optional: {
              my_optional_key: {
                level_1: 1
              }
            },
          )

          value = {
            my_optional_key: {
              level_1: 2
            }
          }

          expect(Xpect::Spec).to receive(:conform!).with(
            {
              spec: {level_1: 1},
              data: {level_1: 2},
              path: [:my_optional_key]
            }
          )

          keys.conform!(value: value)
        end
      end
    end

    context 'when comparing value with Pred' do
      context 'when value is equal' do
        it 'should return data with optional keys' do
          keys = described_class.new(
            optional: {
              my_optional_key: Xpect::Pred.new(
                pred: lambda {|v| v == 'my_optional_key'}
              )
            },
          )

          value = {
            my_optional_key: 'my_optional_key'
          }

          expect(keys.conform!(value: value)).to eq(
                                                   {
                                                     my_optional_key: 'my_optional_key'
                                                   }
                                                 )
        end
      end

      context 'when value is not equal' do
        it 'should raise FailedSpec' do
          keys = described_class.new(
            optional: {
              my_optional_key: Xpect::Pred.new(
                pred: lambda {|v| v == 'my_optional_key'}
              )
            },
          )

          value = {
            my_optional_key: 'not_a_match'
          }

          expect {
            keys.conform!(value: value)
          }.to raise_error(Xpect::FailedSpec, "'not_a_match' does not meet spec for '[:my_optional_key]'")
        end
      end
    end

    context 'when comparing value with Proc' do
      context 'when value is equal' do
        it 'should return data with optional keys' do
          keys = described_class.new(
            optional: {
              my_optional_key: lambda {|v| v == 'my_optional_key'}
            },
          )

          value = {
            my_optional_key: 'my_optional_key'
          }

          expect(keys.conform!(value: value)).to eq(
                                                   {
                                                     my_optional_key: 'my_optional_key'
                                                   }
                                                 )
        end
      end

      context 'when value is not equal' do
        it 'should raise FailedSpec' do
          keys = described_class.new(
            optional: {
              my_optional_key: lambda {|v| v == 'my_optional_key'}
            },
          )

          value = {
            my_optional_key: 'not_a_match'
          }

          expect {
            keys.conform!(value: value)
          }.to raise_error(Xpect::FailedSpec, "'not_a_match' does not meet expectation at '[]'")
        end
      end
    end

    context 'when comparing value equality' do
      context 'when value is equal' do
        it 'should return data with optional keys' do
          keys = described_class.new(
            optional: {
              my_optional_key: 'my_optional_key'
            },
          )

          value = {
            my_optional_key: 'my_optional_key'
          }

          expect(keys.conform!(value: value)).to eq(
            {
              my_optional_key: 'my_optional_key'
            }
          )
        end
      end

      context 'when value is not equal' do
        it 'should raise FailedSpec' do
          keys = described_class.new(
            optional: {
              my_optional_key: 'my_optional_key'
            },
          )

          value = {
            my_optional_key: 'does not match'
          }

          expect{
            keys.conform!(value: value)
          }.to raise_error(Xpect::FailedSpec, "'does not match' is not equal to 'my_optional_key' at '[]'")
        end
      end
    end

  end

  context 'with optional and required options' do
    it 'returns only the specified keys' do
      keys = described_class.new(
        required: {
          my_required_key: 'my_required_key'
        },
        optional: {
          my_optional_key: 'my_optional_key'
        },
      )

      value = {
        do_not_return_me: 'do not return me',
        my_optional_key: 'my_optional_key',
        my_required_key: 'my_required_key'
      }

      expect(
        keys.conform!(value: value)
      ).to eq(
             {
               my_optional_key: 'my_optional_key',
               my_required_key: 'my_required_key'
             }
           )
    end

    context 'when optional key is not present in data' do
      it 'should return the required keys' do
        keys = described_class.new(
          required: {
            my_required_key: 'my_required_key'
          },
          optional: {
            my_optional_key: 'my_optional_key'
          },
        )

        value = {
          my_required_key: 'my_required_key'
        }

        expect(
          keys.conform!(value: value)
        ).to eq({my_required_key: 'my_required_key'})
      end
    end

    context 'when optional key is present in data' do
      it 'should return the required and optional keys' do
        keys = described_class.new(
          required: {
            my_required_key: 'my_required_key'
          },
          optional: {
            my_optional_key: 'my_optional_key'
          },
        )

        value = {
          my_required_key: 'my_required_key',
          my_optional_key: 'my_optional_key'
        }

        expect(keys.conform!(value: value)).to eq(
          {
            my_required_key: 'my_required_key',
            my_optional_key: 'my_optional_key'
          }
        )
      end
    end
  end
end