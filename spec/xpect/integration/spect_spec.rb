RSpec.describe Xpect::Spect do
  context '.validate!' do
    context 'using Matchers' do
      context 'when truthy' do
        it 'returns data when valid' do
          spec = {
            return_me_1: Xpect::Matchers.truthy,
            return_me_2: 'return_me_2'
          }
          data = {
            return_me_1: 'return_me_1',
            return_me_2: 'return_me_2',
            return_me_3: 'return_me_3',
          }

          expect(described_class.validate!(spec, data)).to eq data
        end

        it 'returns data when valid' do
          spec = {
            return_me_1: Xpect::Matchers.anything,
            return_me_2: 'return_me_2'
          }
          data = {
            return_me_1: [1,2,3],
            return_me_2: 'return_me_2',
            return_me_3: 'return_me_3',
          }

          expect(described_class.validate!(spec, data)).to eq data
        end
      end

      context 'when falsy' do
        it 'raises FailedSpec' do
          spec = {
            return_me_1: Xpect::Matchers.truthy,
            return_me_2: 'return_me_2'
          }
          data = {
            return_me_1: nil,
            return_me_2: 'return_me_2',
            return_me_3: 'return_me_3',
          }

          expect {
            described_class.validate!(spec, data)
          }.to raise_error(Xpect::FailedSpec, "'' is not truthy.")
        end

        it 'raises FailedSpec' do
          spec = {
            return_me_1: Xpect::Matchers.falsy,
            return_me_2: 'return_me_2'
          }
          data = {
            return_me_1: 2,
            return_me_2: 'return_me_2',
            return_me_3: 'return_me_3',
          }

          expect {
            described_class.validate!(spec, data)
          }.to raise_error(Xpect::FailedSpec, "'2' is not falsy.")
        end
      end
    end

    context 'comparing with a Pred' do
      context 'when equal' do
        it 'returns data when valid' do
          spec = {
            return_me_1: Xpect::Pred.new(
              pred: lambda {|v| v == 'return_me_1'}
            ),
            return_me_2: 'return_me_2'
          }
          data = {
            return_me_1: 'return_me_1',
            return_me_2: 'return_me_2',
          }

          expect(described_class.validate!(spec, data)).to eq data
        end
      end

      context 'when not equal' do
        it 'raises FailedSpec' do
          spec = {
            return_me_1: Xpect::Pred.new(
              pred: lambda {|v| v == 'return_me_1'}
            ),
            return_me_2: 'return_me_2'
          }
          data = {
            return_me_1: 'not_a_match',
            return_me_2: 'return_me_2',
          }

          expect {
            described_class.validate!(spec, data)
          }.to raise_error(Xpect::FailedSpec)
        end
      end

      context 'default values' do
        it 'should use default value from Pred value not present' do
          spec = {
            return_me_1: Xpect::Pred.new(
              pred: lambda {|v| v == 'return_me_1'},
              default: 'my_default'
            ),
            return_me_2: 'return_me_2'
          }
          data = {
            return_me_2: 'return_me_2',
            not_in_spec: 'not_in_spec'
          }

          expect(described_class.validate!(spec, data)).to eq(
                                                             {
                                                               return_me_1: 'my_default',
                                                               return_me_2: 'return_me_2',
                                                               not_in_spec: 'not_in_spec'
                                                             }
                                                           )
        end
      end
    end

    context 'comparing with Keys' do
      context 'when requiring keys' do
        context 'when equal' do
          it 'returns data when valid' do
            spec = {
              return_me_1: Xpect::Keys.new(
                required: {
                  level_1: 1,
                  level_2: 2
                }
              ),
              return_me_2: 'return_me_2'
            }
            data = {
              return_me_1: {
                level_1: 1,
                level_2: 2,
                level_3: 3
              },
              return_me_2: 'return_me_2',
            }

            expect(described_class.validate!(spec, data)).to eq data
          end
        end

        context 'when not equal' do
          it 'raises FailedSpec' do
            spec = {
              return_me_1: Xpect::Keys.new(
                required: {
                  level_1: 1,
                  level_2: 2
                }
              ),
              return_me_2: 'return_me_2'
            }
            data = {
              return_me_1: {
                level_1: 1,
                level_3: 3
              },
              return_me_2: 'return_me_2',
            }

            expect {
              described_class.validate!(spec, data)
            }.to raise_error(Xpect::FailedSpec, "does not include 'level_2' at '[:return_me_1]'")
          end
        end
      end
    end

    context 'nested specs' do
      context 'nested Keys' do
        context 'with optional and required keys' do
          context 'when valid' do
            it 'should return required and optional keys' do
              spec = {
                return_me_1: {
                  level_1: Xpect::Keys.new(
                    required: {
                      level_2: 'level_2'
                    },
                    optional: {
                      level_2_1_optional: 'level_2_optional',
                      level_2_2_optional: Xpect::Keys.new(
                        required: {
                          level_3_1: 'level_3_1'
                        }
                      )
                    }
                  )
                }
              }

              data = {
                return_me_1: {
                  level_1: {
                    level_2: 'level_2',
                    level_2_2_optional: {
                      level_3_1: 'level_3_1'
                    }
                  }
                }
              }

              expect(described_class.validate!(spec, data)).to eq(data)
            end
          end

          context 'when invalid' do
            it 'should raise FailedSpec' do
              spec = {
                return_me_1: {
                  level_1: Xpect::Keys.new(
                    required: {
                      level_2: 'level_2'
                    },
                    optional: {
                      level_2_1_optional: 'level_2_optional',
                      level_2_2_optional: Xpect::Keys.new(
                        required: {
                          level_3_1: 'level_3_1'
                        }
                      )
                    }
                  )
                }
              }

              data = {
                return_me_1: {
                  level_1: {
                    level_2: 'level_2',
                    level_2_2_optional: {
                      level_3_1: 'not_a_match'
                    }
                  }
                }
              }

              expect {
                described_class.validate!(spec, data)
              }.to raise_error(Xpect::FailedSpec)
            end
          end
        end

        context 'with required keys' do
          context 'when valid' do
            it 'should return all required keys' do
              spec = {
                return_me_1: Xpect::Keys.new(
                  required: {
                    level_1_1: 'level_1_1',
                    level_1_2: Xpect::Keys.new(
                      required: {
                        level_2_1: 'level_2_1',
                        level_2_2: Xpect::Keys.new(
                          required: {
                            level_3_1: 'level_3_1'
                          }
                        )
                      }
                    )
                  }
                )
              }

              data = {
                return_me_1: {
                  level_1_1: 'level_1_1',
                  level_1_2: {
                    level_2_1: 'level_2_1',
                    level_2_2: {
                      level_3_1: 'level_3_1',
                      level_3_2: 'not_in_spec'
                    }
                  }
                }
              }

              expect(described_class.validate!(spec, data)).to eq(data)
            end
          end

          context 'when invalid' do
            it 'should return all required keys' do
              spec = {
                return_me_1: Xpect::Keys.new(
                  required: {
                    level_1_1: 'level_1_1',
                    level_1_2: Xpect::Keys.new(
                      required: {
                        level_2_1: 'level_2_1',
                        level_2_2: Xpect::Keys.new(
                          required: {
                            level_3_1: 'level_3_1'
                          }
                        )
                      }
                    )
                  }
                )
              }

              data = {
                return_me_1: {
                  level_1_1: 'level_1_1',
                  level_1_2: {
                    level_2_1: 'level_2_1',
                    level_2_2: {
                      level_3_2: 'not_in_spec'
                    }
                  }
                }
              }

              expect {
                described_class.validate!(spec, data)
              }.to raise_error(Xpect::FailedSpec)
            end
          end
        end

        context 'with optional keys' do
          context 'when valid' do
            it 'should return all optional keys' do
              spec = {
                return_me_1: Xpect::Keys.new(
                  optional: {
                    level_1_1: 'level_1_1',
                    level_1_2: Xpect::Keys.new(
                      optional: {
                        level_2_1: 'level_2_1',
                        level_2_2: Xpect::Keys.new(
                          optional: {
                            level_3_1: 'level_3_1'
                          }
                        )
                      }
                    )
                  }
                )
              }

              data = {
                return_me_1: {
                  level_1_2: {
                    level_2_2: {
                      level_3_1: 'level_3_1',
                      level_3_2: 'not_in_spec'
                    }
                  }
                }
              }

              expect(described_class.validate!(spec, data)).to eq(data)
            end
          end

          context 'when invalid' do
            it 'should raise FailedSpec' do
              spec = {
                return_me_1: Xpect::Keys.new(
                  optional: {
                    level_1_1: 'level_1_1',
                    level_1_2: Xpect::Keys.new(
                      optional: {
                        level_2_1: 'level_2_1',
                        level_2_2: Xpect::Keys.new(
                          optional: {
                            level_3_1: 'level_3_1'
                          }
                        )
                      }
                    )
                  }
                )
              }

              data = {
                return_me_1: {
                  level_1_1: 'level_1_1',
                  level_1_2: {
                    level_2_1: 'not_a_match',
                    level_2_2: {
                      level_3_2: 'not_in_spec'
                    }
                  }
                }
              }

              expect {
                described_class.validate!(spec, data)
              }.to raise_error(Xpect::FailedSpec)
            end
          end
        end
      end

      context 'nested Keys, Procs, and Hashes' do
        context 'when equal' do
          it 'returns data when valid' do
            spec = {
              return_me_1: Xpect::Keys.new(
                required: {
                  level_1: Xpect::Keys.new(
                    required: {
                      level_2_1: 'level_2_1',
                      level_2_2: lambda {|v| v == 'return_me_level_2_2'},
                      level_2_3: Xpect::Pred.new(
                        pred: lambda {|v| v == 'return_me_level_2_3'}
                      ),
                      level_2_4: {
                        level_3: {
                          level_4_1: 'level_4_1',
                          level_4_2: lambda {|v| v == 'level_4_2'}
                        }
                      }
                    }
                  ),
                  level_1_2: 'level_1_2'
                }
              ),
              return_me_2: 'return_me_2'
            }

            data = {
              return_me_1: {
                level_1: {
                  level_2_1: 'level_2_1',
                  level_2_2: 'return_me_level_2_2',
                  level_2_3: 'return_me_level_2_3',
                  level_2_4: {
                    level_3: {
                      level_4_1: 'level_4_1',
                      level_4_2: 'level_4_2',
                      level_4_3: 'not a required key'
                    }
                  }
                },
                level_1_2: 'level_1_2'
              },
              return_me_2: 'return_me_2',
            }

            expect(described_class.validate!(spec, data)).to eq data
          end
        end

        context 'when not equal' do
          it 'raises FailedSpec' do
            spec = {
              return_me_1: Xpect::Keys.new(
                required: {
                  level_1: Xpect::Keys.new(
                    required: {
                      level_2_1: 'level_2_1',
                      level_2_2: lambda {|v| v == 'return_me_level_2_2'},
                      level_2_3: Xpect::Pred.new(
                        pred: lambda {|v| v == 'return_me_level_2_3'}
                      ),
                      level_2_4: {
                        level_3: {
                          level_4_1: 'level_4_1',
                          level_4_2: lambda {|v| v == 'level_4_2'}
                        }
                      }
                    }
                  )
                }
              ),
              return_me_2: 'return_me_2'
            }
            data = {
              return_me_1: {
                level_1: {
                  level_2_1: 'level_2_1',
                  level_2_2: 'return_me_level_2_2',
                  level_2_3: 'return_me_level_2_3',
                  level_2_4: {
                    level_3: {
                      level_4_1: 'level_4_1',
                      level_4_2: 'not_a_match',
                      level_4_3: 'not a required key'
                    }
                  }
                }
              },
              return_me_2: 'return_me_2',
            }

            expect {
              described_class.validate!(spec, data)
            }.to raise_error(Xpect::FailedSpec)
          end
        end
      end
    end

    context 'when contains arrays' do
      context 'when equal' do
        context 'comparing every item in array' do
          context 'when equal' do
            context 'item is a String' do
              it 'should return data' do
                spec = {
                  return_me_2: Xpect::Every.new(
                    'hello'
                  )
                }
                data = {
                  return_me_2: [
                    'hello',
                    'hello'
                  ]
                }

                expect(
                  described_class.validate!(spec, data)
                ).to eq(data)
              end

            end

            context 'item is a Hash' do
              it 'should return data' do
                spec = {
                  return_me_2: Xpect::Every.new(
                    {
                      return_me_1: 'return_me_1',
                      return_me_2: 'return_me_2'
                    }
                  )
                }
                data = {
                  return_me_2: [
                    {
                      return_me_1: 'return_me_1',
                      return_me_2: 'return_me_2'
                    },
                    {
                      return_me_1: 'return_me_1',
                      return_me_2: 'return_me_2'
                    }
                  ]
                }

                expect(
                  described_class.validate!(spec, data)
                ).to eq(data)
              end
            end

            context 'item is a Proc' do
              it 'should return data' do
                spec = {
                  return_me_2: Xpect::Every.new(
                    lambda {|v| v == 'return_me_1'}
                  )
                }
                data = {
                  return_me_2: [
                    'return_me_1',
                    'return_me_1'
                  ]
                }

                expect(
                  described_class.validate!(spec, data)
                ).to eq(data)
              end
            end

            context 'item is a Proc' do
              it 'should return data' do
                spec = {
                  return_me_2: Xpect::Every.new(
                    Xpect::Pred.new(
                      pred: lambda {|v| v == 'return_me_1'}
                    )
                  )
                }
                data = {
                  return_me_2: [
                    'return_me_1',
                    'return_me_1'
                  ]
                }

                expect(
                  described_class.validate!(spec, data)
                ).to eq(data)
              end
            end

            context 'item is a Keys' do
              it 'should return data' do
                spec = {
                  return_me_2: Xpect::Every.new(
                    Xpect::Keys.new(
                      required: {
                        item_1: 'item_1',
                        item_2: 'item_2',
                      }
                    )
                  )
                }
                data = {
                  return_me_2: [
                    {
                      item_1: 'item_1',
                      item_2: 'item_2'
                    }
                  ]
                }

                expect(
                  described_class.validate!(spec, data)
                ).to eq(data)
              end

              it 'should return data' do
                spec = {
                  return_me_2: Xpect::Every.new(
                    Xpect::Keys.new(
                      required: {
                        item_1: [
                          'one',
                          'two'
                        ],
                        item_2: 'item_2',
                      }
                    )
                  )
                }
                data = {
                  return_me_2: [
                    {
                      item_1: [
                        'one',
                        'two',
                        'three'
                      ],
                      item_2: 'item_2'
                    }
                  ]
                }

                expect(
                  described_class.validate!(spec, data)
                ).to eq(data)
              end
            end
          end
        end

        it 'should return data' do
          spec = {
            return_me_2: [
              {
                return_me_1: 'return_me_1',
                return_me_2: 'return_me_2'
              }
            ]
          }
          data = {
            return_me_2: [
              {
                return_me_1: 'return_me_1',
                return_me_2: 'return_me_2'
              }
            ]
          }

          expect(
            described_class.validate!(spec, data)
          ).to eq(data)
        end

        context 'when data has more array items than spec array items' do
          it 'should raise FailedSpec' do
            spec = {
              return_me_2: [
                {
                  return_me_1: 'return_me_1',
                  return_me_2: 'return_me_2'
                }
              ]
            }
            data = {
              return_me_2: [
                {
                  return_me_1: 'return_me_1',
                  return_me_2: 'return_me_2'
                },
                {
                  return_me_1: 'return_me_1',
                  return_me_2: 'return_me_2'
                }
              ]
            }

            expect(
              described_class.validate!(spec, data)
            ).to eq(data)
          end
        end

        context 'arrays inside of arrays' do
          it 'should return data' do
            spec = {
              return_me_2: [
                {
                  return_me_1: 'return_me_1',
                  return_me_2: [
                    'one',
                    'two',
                    [
                      1,
                      2,
                      3
                    ]
                  ]
                }
              ]
            }
            data = {
              return_me_2: [
                {
                  return_me_1: 'return_me_1',
                  return_me_2: [
                    'one',
                    'two',
                    [
                      1,
                      2,
                      3
                    ]
                  ]
                }
              ]
            }

            expect(
              described_class.validate!(spec, data)
            ).to eq(data)
          end
        end

        context 'when item is a Key' do
          it 'should return data' do
            spec = {
              return_me_2: [
                {
                  return_me_1: 'return_me_1',
                  return_me_2: [
                    'one',
                    'two',
                    Xpect::Keys.new(
                      required: {
                        level_1: 1,
                        level_2: 2
                      }
                    )
                  ]
                }
              ]
            }
            data = {
              return_me_2: [
                {
                  return_me_1: 'return_me_1',
                  return_me_2: [
                    'one',
                    'two',
                    {
                      level_1: 1,
                      level_2: 2
                    }
                  ]
                },
              ],
              not_in_spec: 'not_in_spec'
            }

            expect(
              described_class.validate!(spec, data)
            ).to eq(data)
          end

          # TODO: move this to keys_spec.rb
          context 'when Key contains an array' do
            context 'when value compared directly' do
              it 'should return data' do
                spec = {
                  return_me_2: [
                    {
                      return_me_1: 'return_me_1',
                      return_me_2: [
                        'one',
                        'two',
                        Xpect::Keys.new(
                          required: {
                            level_1: 1,
                            level_2: [
                              'three',
                              'four'
                            ]
                          }
                        )
                      ]
                    }
                  ]
                }
                data = {
                  return_me_2: [
                    {
                      return_me_1: 'return_me_1',
                      return_me_2: [
                        'one',
                        'two',
                        {
                          level_1: 1,
                          level_2: [
                            'three',
                            'four',
                            'five'
                          ]
                        }
                      ]
                    },
                  ],
                  not_in_spec: 'not_in_spec'
                }

                expect(
                  described_class.validate!(spec, data)
                ).to eq(data)
              end
            end

            context 'when value is a hash' do
              it 'should return data' do
                spec = {
                  return_me_2: [
                    {
                      return_me_1: 'return_me_1',
                      return_me_2: [
                        'one',
                        'two',
                        Xpect::Keys.new(
                          required: {
                            level_1: 1,
                            level_2: [
                              'three',
                              {
                                a: 'a',
                                b: 'b'
                              }
                            ]
                          }
                        )
                      ]
                    }
                  ]
                }
                data = {
                  return_me_2: [
                    {
                      return_me_1: 'return_me_1',
                      return_me_2: [
                        'one',
                        'two',
                        {
                          level_1: 1,
                          level_2: [
                            'three',
                            {
                              a: 'a',
                              b: 'b'
                            },
                            'five'
                          ]
                        }
                      ]
                    },
                  ],
                  not_in_spec: 'not_in_spec'
                }

                expect(
                  described_class.validate!(spec, data)
                ).to eq(data)
              end
            end

            context 'when value is a Pred' do
              it 'should raise FailedSpec' do
                spec = {
                  return_me_2: [
                    {
                      return_me_1: 'return_me_1',
                      return_me_2: [
                        'one',
                        'two',
                        Xpect::Keys.new(
                          required: {
                            level_1: 1,
                            level_2: [
                              'three',
                              Xpect::Pred.new(
                                pred: lambda {|v| v == 'four'}
                              )
                            ]
                          }
                        )
                      ]
                    }
                  ]
                }
                data = {
                  return_me_2: [
                    {
                      return_me_1: 'return_me_1',
                      return_me_2: [
                        'one',
                        'two',
                        {
                          level_1: 1,
                          level_2: [
                            'three',
                            'four',
                            'five'
                          ]
                        }
                      ]
                    },
                  ],
                  not_in_spec: 'not_in_spec'
                }

                expect(
                  described_class.validate!(spec, data)
                ).to eq(data)
              end
            end

            context 'when value is a Keys' do
              it 'should return data' do
                spec = {
                  return_me_2: [
                    {
                      return_me_1: 'return_me_1',
                      return_me_2: [
                        'one',
                        'two',
                        Xpect::Keys.new(
                          required: {
                            level_1: 1,
                            level_2: [
                              'three',
                              Xpect::Keys.new(
                                required: {
                                  a: 'a',
                                  b: 'b'
                                }
                              )
                            ]
                          }
                        )
                      ]
                    }
                  ]
                }
                data = {
                  return_me_2: [
                    {
                      return_me_1: 'return_me_1',
                      return_me_2: [
                        'one',
                        'two',
                        {
                          level_1: 1,
                          level_2: [
                            'three',
                            {
                              a: 'a',
                              b: 'b'
                            },
                            'five'
                          ]
                        }
                      ]
                    },
                  ],
                  not_in_spec: 'not_in_spec'
                }

                expect(
                  described_class.validate!(spec, data)
                ).to eq(data)
              end
            end

            context 'when value is a Proc' do
              it 'should return data' do
                spec = {
                  return_me_2: [
                    {
                      return_me_1: 'return_me_1',
                      return_me_2: [
                        'one',
                        'two',
                        Xpect::Keys.new(
                          required: {
                            level_1: 1,
                            level_2: [
                              'three',
                              lambda {|v| v == 'four'}
                            ]
                          }
                        )
                      ]
                    }
                  ]
                }
                data = {
                  return_me_2: [
                    {
                      return_me_1: 'return_me_1',
                      return_me_2: [
                        'one',
                        'two',
                        {
                          level_1: 1,
                          level_2: [
                            'three',
                            'four',
                            'five'
                          ]
                        }
                      ]
                    },
                  ],
                  not_in_spec: 'not_in_spec'
                }

                expect(
                  described_class.validate!(spec, data)
                ).to eq(data)
              end
            end
          end
        end

        context 'when item is a Pred' do
          it 'should return data' do
            spec = {
              return_me_2: [
                {
                  return_me_1: 'return_me_1',
                  return_me_2: [
                    'one',
                    'two',
                    Xpect::Pred.new(
                      pred: lambda {|v| v == 'return_me_1'}
                    ),
                  ]
                }
              ]
            }
            data = {
              return_me_2: [
                {
                  return_me_1: 'return_me_1',
                  return_me_2: [
                    'one',
                    'two',
                    'return_me_1'
                  ]
                },
              ],
              not_in_spec: 'not_in_spec'
            }

            expect(
              described_class.validate!(spec, data)
            ).to eq(data)
          end

          context 'with default value' do
            it 'should return data' do
              spec = {
                return_me_2: [
                  {
                    return_me_1: 'return_me_1',
                    return_me_2: [
                      'one',
                      'two',
                      Xpect::Pred.new(
                        pred: lambda {|v| v == 'return_me_1'},
                        default: 'my_default'
                      ),
                    ]
                  }
                ]
              }
              data = {
                return_me_2: [
                  {
                    return_me_1: 'return_me_1',
                    return_me_2: [
                      'one',
                      'two'
                    ]
                  },
                ]
              }

              expect(
                described_class.validate!(spec, data)
              ).to eq(
                     {
                       return_me_2: [
                         {
                           return_me_1: 'return_me_1',
                           return_me_2: [
                             'one',
                             'two',
                             'my_default'
                           ]
                         },
                       ]
                     }
                   )
            end
          end
        end

        context 'when item is a Hash' do
          it 'should return data' do
            spec = {
              return_me_2: [
                {
                  return_me_1: 'return_me_1',
                  return_me_2: [
                    'one',
                    'two',
                    {
                      a: 'a',
                      b: lambda {|v| v == 'b' }
                    }
                  ]
                }
              ]
            }
            data = {
              return_me_2: [
                {
                  return_me_1: 'return_me_1',
                  return_me_2: [
                    'one',
                    'two',
                    {
                      a: 'a',
                      b: 'b'
                    },
                  ]
                },
              ]
            }

            expect(
              described_class.validate!(spec, data)
            ).to eq(data)
          end
        end

        context 'when item in array contains a Proc' do
          it 'should return data' do
            spec = {
              return_me_2: [
                1,
                lambda {|v| v > 5}

              ]
            }

            data = {
              return_me_2: [
                1,
                45
              ]
            }

            expect(
              described_class.validate!(spec, data)
            ).to eq(data)
          end
        end
      end

      context 'when unequal' do
        context 'comparing every item in array' do
          context 'when equal' do
            context 'item is a String' do
              it 'should raise FailedSpec' do
                spec = {
                  return_me_2: Xpect::Every.new(
                    'hello'
                  )
                }
                data = {
                  return_me_2: [
                    'hello',
                    'does_not_conform'
                  ]
                }

                expect {
                  described_class.validate!(spec, data)
                }.to raise_error(Xpect::FailedSpec)
              end
            end

            context 'item is a Hash' do
              it 'should return data' do
                spec = {
                  return_me_2: Xpect::Every.new(
                    {
                      return_me_1: 'return_me_1',
                      return_me_2: 'return_me_2'
                    }
                  )
                }
                data = {
                  return_me_2: [
                    {
                      return_me_1: 'return_me_1',
                      return_me_2: 'return_me_2'
                    },
                    {
                      return_me_1: 'does_not_conform',
                      return_me_2: 'return_me_2'
                    }
                  ]
                }

                expect {
                  described_class.validate!(spec, data)
                }.to raise_error(Xpect::FailedSpec)
              end
            end

            context 'item is a Proc' do
              it 'should return data' do
                spec = {
                  return_me_2: Xpect::Every.new(
                    lambda {|v| v == 'return_me_1'}
                  )
                }
                data = {
                  return_me_2: [
                    'return_me_1',
                    'does_not_conform'
                  ]
                }

                expect {
                  described_class.validate!(spec, data)
                }.to raise_error(Xpect::FailedSpec)
              end
            end

            context 'item is a Proc' do
              it 'should return data' do
                spec = {
                  return_me_2: Xpect::Every.new(
                    Xpect::Pred.new(
                      pred: lambda {|v| v == 'return_me_1'}
                    )
                  )
                }
                data = {
                  return_me_2: [
                    'return_me_1',
                    'does_not_conform'
                  ]
                }

                expect {
                  described_class.validate!(spec, data)
                }.to raise_error(Xpect::FailedSpec)
              end
            end

            context 'item is a Keys' do
              it 'should return data' do
                spec = {
                  return_me_2: Xpect::Every.new(
                    Xpect::Keys.new(
                      required: {
                        item_1: 'item_1',
                        item_2: 'item_2',
                      }
                    )
                  )
                }
                data = {
                  return_me_2: [
                    {
                      item_1: 'item_1',
                      not_a_required_key: 'not_a_required_kdy'
                    }
                  ]
                }

                expect {
                  described_class.validate!(spec, data)
                }.to raise_error(Xpect::FailedSpec)
              end

              it 'should return data' do
                spec = {
                  return_me_2: Xpect::Every.new(
                    Xpect::Keys.new(
                      required: {
                        item_1: [
                          'one',
                          'two'
                        ],
                        item_2: 'item_2',
                      }
                    )
                  )
                }
                data = {
                  return_me_2: [
                    {
                      item_1: [
                        'one',
                        'does_not_conform',
                        'three'
                      ],
                      item_2: 'item_2'
                    }
                  ]
                }

                expect {
                  described_class.validate!(spec, data)
                }.to raise_error(Xpect::FailedSpec)
              end
            end
          end
        end
        
        it 'should raise FailedSpec' do
          spec = {
            return_me_2: [
              {
                return_me_1: 'return_me_1',
                return_me_2: 'return_me_2'
              }
            ]
          }
          data = {
            return_me_2: [
              {
                return_me_1: 'return_me_1',
                return_me_2: 'not_to_spec'
              }
            ]
          }

          expect {
            described_class.validate!(spec, data)
          }.to raise_error(Xpect::FailedSpec)
        end

        context 'when item is a Key' do
          it 'should raise FailedSpec' do
            spec = {
              return_me_2: [
                {
                  return_me_1: 'return_me_1',
                  return_me_2: [
                    'one',
                    'two',
                    Xpect::Keys.new(
                      required: {
                        level_1: 1,
                        level_2: 2
                      }
                    )
                  ]
                }
              ]
            }
            data = {
              return_me_2: [
                {
                  return_me_1: 'return_me_1',
                  return_me_2: [
                    'one',
                    'two',
                    {
                      level_1: 1,
                      not_a_required_key: 2
                    }
                  ]
                },
              ],
              not_in_spec: 'not_in_spec'
            }

            expect {
              described_class.validate!(spec, data)
            }.to raise_error(Xpect::FailedSpec)
          end

          # TODO: move this to keys_spec.rb
          context 'when Key contains an array' do
            it 'should raise FailedSpec' do
              spec = {
                return_me_2: [
                  {
                    return_me_1: 'return_me_1',
                    return_me_2: [
                      'one',
                      'two',
                      Xpect::Keys.new(
                        required: {
                          level_1: 1,
                          level_2: [
                            'three',
                            'four'
                          ]
                        }
                      )
                    ]
                  }
                ]
              }
              data = {
                return_me_2: [
                  {
                    return_me_1: 'return_me_1',
                    return_me_2: [
                      'one',
                      'two',
                      {
                        level_1: 1,
                        level_2: [
                          'three',
                          'not_a_match',
                          'five'
                        ]
                      }
                    ]
                  },
                ],
                not_in_spec: 'not_in_spec'
              }

              expect {
                described_class.validate!(spec, data)
              }.to raise_error(Xpect::FailedSpec)
            end
          end

          context 'when Key array item is a hash' do
            it 'should raise FailedSpec' do
              spec = {
                return_me_2: [
                  {
                    return_me_1: 'return_me_1',
                    return_me_2: [
                      'one',
                      'two',
                      Xpect::Keys.new(
                        required: {
                          level_1: 1,
                          level_2: [
                            'three',
                            {
                              a: 'a',
                              b: 'b'
                            }
                          ]
                        }
                      )
                    ]
                  }
                ]
              }
              data = {
                return_me_2: [
                  {
                    return_me_1: 'return_me_1',
                    return_me_2: [
                      'one',
                      'two',
                      {
                        level_1: 1,
                        level_2: [
                          'three',
                          {
                            a: 'a',
                            b: 'not_a_match'
                          },
                          'five'
                        ]
                      }
                    ]
                  },
                ],
                not_in_spec: 'not_in_spec'
              }

              expect {
                described_class.validate!(spec, data)
              }.to raise_error(Xpect::FailedSpec)
            end
          end

          context 'when value is a Pred' do
            it 'should raise FailedSpec' do
              spec = {
                return_me_2: [
                  {
                    return_me_1: 'return_me_1',
                    return_me_2: [
                      'one',
                      'two',
                      Xpect::Keys.new(
                        required: {
                          level_1: 1,
                          level_2: [
                            'three',
                            Xpect::Pred.new(
                              pred: lambda {|v| v == 'four'}
                            )
                          ]
                        }
                      )
                    ]
                  }
                ]
              }
              data = {
                return_me_2: [
                  {
                    return_me_1: 'return_me_1',
                    return_me_2: [
                      'one',
                      'two',
                      {
                        level_1: 1,
                        level_2: [
                          'three',
                          'not_a_match',
                          'five'
                        ]
                      }
                    ]
                  },
                ],
                not_in_spec: 'not_in_spec'
              }

              expect {
                described_class.validate!(spec, data)
              }.to raise_error(Xpect::FailedSpec)
            end
          end

          context 'when value is a Keys' do
            it 'should raise FailedSpec' do
              spec = {
                return_me_2: [
                  {
                    return_me_1: 'return_me_1',
                    return_me_2: [
                      'one',
                      'two',
                      Xpect::Keys.new(
                        required: {
                          level_1: 1,
                          level_2: [
                            'three',
                            Xpect::Keys.new(
                              required: {
                                a: 'a',
                                b: 'b'
                              }
                            )
                          ]
                        }
                      )
                    ]
                  }
                ]
              }
              data = {
                return_me_2: [
                  {
                    return_me_1: 'return_me_1',
                    return_me_2: [
                      'one',
                      'two',
                      {
                        level_1: 1,
                        level_2: [
                          'three',
                          {
                            a: 'a',
                            not_a_required_key: 'not_a_required_key'
                          },
                          'five'
                        ]
                      }
                    ]
                  },
                ],
                not_in_spec: 'not_in_spec'
              }

              expect {
                described_class.validate!(spec, data)
              }.to raise_error(Xpect::FailedSpec)
            end
          end

          context 'when value is a Proc' do
            it 'should raise FailedSpec' do
              spec = {
                return_me_2: [
                  {
                    return_me_1: 'return_me_1',
                    return_me_2: [
                      'one',
                      'two',
                      Xpect::Keys.new(
                        required: {
                          level_1: 1,
                          level_2: [
                            'three',
                            lambda {|v| v == 'four'}
                          ]
                        }
                      )
                    ]
                  }
                ]
              }
              data = {
                return_me_2: [
                  {
                    return_me_1: 'return_me_1',
                    return_me_2: [
                      'one',
                      'two',
                      {
                        level_1: 1,
                        level_2: [
                          'three',
                          'not_a_match',
                          'five'
                        ]
                      }
                    ]
                  },
                ],
                not_in_spec: 'not_in_spec'
              }

              expect {
                described_class.validate!(spec, data)
              }.to raise_error(Xpect::FailedSpec)
            end
          end
        end

        context 'when item is a Pred' do
          it 'should raise FailedSpec' do
            spec = {
              return_me_2: [
                {
                  return_me_1: 'return_me_1',
                  return_me_2: [
                    'one',
                    'two',
                    Xpect::Pred.new(
                      pred: lambda {|v| v == 'return_me_1'}
                    ),
                  ]
                }
              ]
            }
            data = {
              return_me_2: [
                {
                  return_me_1: 'return_me_1',
                  return_me_2: [
                    'one',
                    'two',
                    'not_a_match'
                  ]
                },
              ]
            }

            expect {
              described_class.validate!(spec, data)
            }.to raise_error(Xpect::FailedSpec)
          end
        end

        context 'when item is a Hash' do
          it 'should raise FailedSpec' do
            spec = {
              return_me_2: [
                {
                  return_me_1: 'return_me_1',
                  return_me_2: [
                    'one',
                    'two',
                    {
                      a: 'a',
                      b: lambda {|v| v == 'b' }
                    }
                  ]
                }
              ]
            }
            data = {
              return_me_2: [
                {
                  return_me_1: 'return_me_1',
                  return_me_2: [
                    'one',
                    'two',
                    {
                      a: 'a',
                      b: 'c'
                    },
                  ]
                },
              ]
            }

            expect {
              described_class.validate!(spec, data)
            }.to raise_error(Xpect::FailedSpec)
          end
        end

        context 'when wrong number of items' do


          it 'should raise FailedSpec' do
            spec = {
              return_me_2: [
                {
                  return_me_1: 'return_me_1',
                  return_me_2: 'return_me_2'
                },
                {
                  return_me_1: 'return_me_1',
                  return_me_2: 'return_me_2'
                }
              ]
            }
            data = {
              return_me_2: [
                {
                  return_me_1: 'return_me_1',
                  return_me_2: 'return_me_2'
                },
              ]
            }

            expect {
              described_class.validate!(spec, data)
            }.to raise_error(Xpect::FailedSpec)
          end
        end

        it 'should raise FailedSpec' do
          spec = {
            return_me_1: {
              return_me_2: lambda {|v| v == 'return_me_3'}
            }
          }
          data = {
            return_me_1: {
              return_me_2: 'not_equal'
            }
          }

          expect {
            described_class.validate!(spec, data)
          }.to raise_error(Xpect::FailedSpec)
        end

        context 'arrays inside of arrays' do
          it 'should raise FailedSpec' do
            spec = {
              return_me_2: [
                {
                  return_me_1: 'return_me_1',
                  return_me_2: [
                    'one',
                    'two',
                    [
                      1,
                      2,
                      3
                    ]
                  ]
                }
              ]
            }
            data = {
              return_me_2: [
                {
                  return_me_1: 'return_me_1',
                  return_me_2: [
                    'one',
                    'two',
                    [
                      1,
                      2,
                      'not_a_match'
                    ]
                  ]
                }
              ]
            }

            expect {
              described_class.validate!(spec, data)
            }.to raise_error(Xpect::FailedSpec)
          end
        end

        context 'when item in array contains a Proc' do
          it 'should raise FailedSpec' do
            spec = {
              return_me_2: [
                1,
                lambda {|v| v > 5}

              ]
            }
            data = {
              return_me_2: [
                1,
                4
              ]
            }

            expect {
              described_class.validate!(spec, data)
            }.to raise_error(Xpect::FailedSpec)
          end
        end
      end
    end
  end

  ### confirm!
  context '.confirm!' do
    context 'using Matchers' do
      context 'when truthy' do
        it 'returns data when valid' do
          spec = {
            return_me_1: Xpect::Matchers.truthy,
            return_me_2: 'return_me_2'
          }
          data = {
            return_me_1: 'return_me_1',
            return_me_2: 'return_me_2',
            return_me_3: 'return_me_3',
          }

          expect(
            described_class.conform!(spec: spec, data: data)
          ).to eq(
                 {
                   return_me_1: 'return_me_1',
                   return_me_2: 'return_me_2',
                 }
               )
        end

        it 'returns data when valid' do
          spec = {
            return_me_1: Xpect::Matchers.anything,
            return_me_2: 'return_me_2'
          }
          data = {
            return_me_1: [1,2,3],
            return_me_2: 'return_me_2',
            return_me_3: 'return_me_3',
          }

          expect(
            described_class.conform!(spec: spec, data: data)
          ).to eq(
                 {
                   return_me_1: [1,2,3],
                   return_me_2: 'return_me_2'
                 }
               )
        end
      end

      context 'when falsy' do
        it 'raises FailedSpec' do
          spec = {
            return_me_1: Xpect::Matchers.truthy,
            return_me_2: 'return_me_2'
          }
          data = {
            return_me_1: nil,
            return_me_2: 'return_me_2',
            return_me_3: 'return_me_3',
          }

          expect {
            described_class.conform!(spec: spec, data: data)
          }.to raise_error(Xpect::FailedSpec, "'' is not truthy.")
        end

        it 'raises FailedSpec' do
          spec = {
            return_me_1: Xpect::Matchers.falsy,
            return_me_2: 'return_me_2'
          }
          data = {
            return_me_1: 2,
            return_me_2: 'return_me_2',
            return_me_3: 'return_me_3',
          }

          expect {
            described_class.conform!(spec: spec, data: data)
          }.to raise_error(Xpect::FailedSpec, "'2' is not falsy.")
        end
      end
    end

    context 'comparing with a Pred' do
      context 'when equal' do
        it 'returns data when valid' do
          spec = {
            return_me_1: Xpect::Pred.new(
              pred: lambda {|v| v == 'return_me_1'}
            ),
            return_me_2: 'return_me_2'
          }
          data = {
            return_me_1: 'return_me_1',
            return_me_2: 'return_me_2',
            return_me_3: 'return_me_3',
          }

          expect(
            described_class.conform!(spec: spec, data: data)
          ).to eq(
                 {
                   return_me_1: 'return_me_1',
                   return_me_2: 'return_me_2',
                 }
               )
        end
      end

      context 'when not equal' do
        it 'raises FailedSpec' do
          spec = {
            return_me_1: Xpect::Pred.new(
              pred: lambda {|v| v == 'return_me_1'}
            ),
            return_me_2: 'return_me_2'
          }
          data = {
            return_me_1: 'not_a_match',
            return_me_2: 'return_me_2',
          }

          expect {
            described_class.conform!(spec: spec, data: data)
          }.to raise_error(Xpect::FailedSpec)
        end
      end

      context 'default values' do
        it 'should use default value from Pred value not present' do
          spec = {
            return_me_1: Xpect::Pred.new(
              pred: lambda {|v| v == 'return_me_1'},
              default: 'my_default'
            ),
            return_me_2: 'return_me_2'
          }
          data = {
            return_me_2: 'return_me_2',
            not_in_spec: 'not_in_spec'
          }

          expect(
            described_class.conform!(spec: spec, data: data)
          ).to eq(
                 {
                   return_me_1: 'my_default',
                   return_me_2: 'return_me_2',
                 }
               )
        end
      end
    end

    context 'comparing with Keys' do
      context 'when requiring keys' do
        context 'when equal' do
          it 'returns data when valid' do
            spec = {
              return_me_1: Xpect::Keys.new(
                required: {
                  level_1: 1,
                  level_2: 2
                }
              ),
              return_me_2: 'return_me_2'
            }
            data = {
              return_me_1: {
                level_1: 1,
                level_2: 2,
                level_3: 3
              },
              return_me_2: 'return_me_2',
            }

            expect(
              described_class.conform!(spec: spec, data: data)
            ).to eq(
                   {
                     return_me_1: {
                       level_1: 1,
                       level_2: 2,
                     },
                     return_me_2: 'return_me_2',
                   }
                 )
          end
        end

        context 'when not equal' do
          it 'raises FailedSpec' do
            spec = {
              return_me_1: Xpect::Keys.new(
                required: {
                  level_1: 1,
                  level_2: 2
                }
              ),
              return_me_2: 'return_me_2'
            }
            data = {
              return_me_1: {
                level_1: 1,
                level_3: 3
              },
              return_me_2: 'return_me_2',
            }

            expect {
              described_class.conform!(spec: spec, data: data)
            }.to raise_error(Xpect::FailedSpec, "does not include 'level_2' at '[:return_me_1]'")
          end
        end
      end
    end

    context 'nested specs' do
      context 'nested Keys' do
        context 'with optional and required keys' do
          context 'when valid' do
            it 'should return required and optional keys' do
              spec = {
                return_me_1: {
                  level_1: Xpect::Keys.new(
                    required: {
                      level_2: 'level_2'
                    },
                    optional: {
                      level_2_1_optional: 'level_2_optional',
                      level_2_2_optional: Xpect::Keys.new(
                        required: {
                          level_3_1: 'level_3_1'
                        }
                      )
                    }
                  )
                }
              }

              data = {
                return_me_1: {
                  level_1: {
                    level_2: 'level_2',
                    level_2_2_optional: {
                      level_3_1: 'level_3_1',
                      do_not_return_me: 'do_not_return_me'
                    }
                  }
                },
                do_not_return_me: 'do_not_return_me'
              }

              expect(
                described_class.conform!(spec: spec, data: data)
              ).to eq(
                     {
                       return_me_1: {
                         level_1: {
                           level_2: 'level_2',
                           level_2_2_optional: {
                             level_3_1: 'level_3_1'
                           }
                         }
                       }
                     }
                   )
            end
          end

          context 'when invalid' do
            it 'should raise FailedSpec' do
              spec = {
                return_me_1: {
                  level_1: Xpect::Keys.new(
                    required: {
                      level_2: 'level_2'
                    },
                    optional: {
                      level_2_1_optional: 'level_2_optional',
                      level_2_2_optional: Xpect::Keys.new(
                        required: {
                          level_3_1: 'level_3_1'
                        }
                      )
                    }
                  )
                }
              }

              data = {
                return_me_1: {
                  level_1: {
                    level_2: 'level_2',
                    level_2_2_optional: {
                      level_3_1: 'not_a_match'
                    }
                  }
                }
              }

              expect {
                described_class.conform!(spec: spec, data: data)
              }.to raise_error(Xpect::FailedSpec)
            end
          end
        end

        context 'with required keys' do
          context 'when valid' do
            it 'should return all required keys' do
              spec = {
                return_me_1: Xpect::Keys.new(
                  required: {
                    level_1_1: 'level_1_1',
                    level_1_2: Xpect::Keys.new(
                      required: {
                        level_2_1: 'level_2_1',
                        level_2_2: Xpect::Keys.new(
                          required: {
                            level_3_1: 'level_3_1'
                          }
                        )
                      }
                    )
                  }
                )
              }

              data = {
                return_me_1: {
                  level_1_1: 'level_1_1',
                  level_1_2: {
                    level_2_1: 'level_2_1',
                    level_2_2: {
                      level_3_1: 'level_3_1',
                      level_3_2: 'not_in_spec'
                    }
                  },
                  level_1_3: 'not_in_spec'
                }
              }

              expect(
                described_class.conform!(spec: spec, data: data)
              ).to eq(
                     {
                       return_me_1: {
                         level_1_1: 'level_1_1',
                         level_1_2: {
                           level_2_1: 'level_2_1',
                           level_2_2: {
                             level_3_1: 'level_3_1',
                           }
                         }
                       }
                     }
                   )
            end
          end

          context 'when invalid' do
            it 'should raise FailedSpec' do
              spec = {
                return_me_1: Xpect::Keys.new(
                  required: {
                    level_1_1: 'level_1_1',
                    level_1_2: Xpect::Keys.new(
                      required: {
                        level_2_1: 'level_2_1',
                        level_2_2: Xpect::Keys.new(
                          required: {
                            level_3_1: 'level_3_1'
                          }
                        )
                      }
                    )
                  }
                )
              }

              data = {
                return_me_1: {
                  level_1_1: 'level_1_1',
                  level_1_2: {
                    level_2_1: 'level_2_1',
                    level_2_2: {
                      level_3_2: 'not_in_spec'
                    }
                  }
                }
              }

              expect {
                described_class.conform!(spec: spec, data: data)
              }.to raise_error(Xpect::FailedSpec)
            end
          end
        end

        context 'with optional keys' do
          context 'when valid' do
            it 'should return all optional keys' do
              spec = {
                return_me_1: Xpect::Keys.new(
                  optional: {
                    level_1_1: 'level_1_1',
                    level_1_2: Xpect::Keys.new(
                      optional: {
                        level_2_1: 'level_2_1',
                        level_2_2: Xpect::Keys.new(
                          optional: {
                            level_3_1: 'level_3_1'
                          }
                        )
                      }
                    )
                  }
                )
              }

              data = {
                return_me_1: {
                  level_1_2: {
                    level_2_2: {
                      level_3_1: 'level_3_1',
                      level_3_2: 'not_in_spec'
                    }
                  }
                }
              }

              expect(
                described_class.conform!(spec: spec, data: data)
              ).to eq(
                     {
                       return_me_1: {
                         level_1_2: {
                           level_2_2: {
                             level_3_1: 'level_3_1',
                           }
                         }
                       }
                     }
                   )
            end
          end

          context 'when invalid' do
            it 'should raise FailedSpec' do
              spec = {
                return_me_1: Xpect::Keys.new(
                  optional: {
                    level_1_1: 'level_1_1',
                    level_1_2: Xpect::Keys.new(
                      optional: {
                        level_2_1: 'level_2_1',
                        level_2_2: Xpect::Keys.new(
                          optional: {
                            level_3_1: 'level_3_1'
                          }
                        )
                      }
                    )
                  }
                )
              }

              data = {
                return_me_1: {
                  level_1_1: 'level_1_1',
                  level_1_2: {
                    level_2_1: 'not_a_match',
                    level_2_2: {
                      level_3_2: 'not_in_spec'
                    }
                  }
                }
              }

              expect {
                described_class.conform!(spec: spec, data: data)
              }.to raise_error(Xpect::FailedSpec)
            end
          end
        end
      end

      context 'nested Keys, Procs, and Hashes' do
        context 'when equal' do
          it 'returns data when valid' do
            spec = {
              return_me_1: Xpect::Keys.new(
                required: {
                  level_1: Xpect::Keys.new(
                    required: {
                      level_2_1: 'level_2_1',
                      level_2_2: lambda {|v| v == 'return_me_level_2_2'},
                      level_2_3: Xpect::Pred.new(
                        pred: lambda {|v| v == 'return_me_level_2_3'}
                      ),
                      level_2_4: {
                        level_3: {
                          level_4_1: 'level_4_1',
                          level_4_2: lambda {|v| v == 'level_4_2'}
                        }
                      }
                    }
                  ),
                  level_1_2: 'level_1_2'
                }
              ),
              return_me_2: 'return_me_2'
            }

            data = {
              return_me_1: {
                level_1: {
                  level_2_1: 'level_2_1',
                  level_2_2: 'return_me_level_2_2',
                  level_2_3: 'return_me_level_2_3',
                  level_2_4: {
                    level_3: {
                      level_4_1: 'level_4_1',
                      level_4_2: 'level_4_2',
                      level_4_3: 'not a required key'
                    }
                  },
                  level_2_5: 'not a required key',
                },
                level_1_2: 'level_1_2'
              },
              return_me_2: 'return_me_2',
            }

            expect(
              described_class.conform!(spec: spec, data: data)
            ).to eq(
                   {
                     return_me_1: {
                       level_1: {
                         level_2_1: 'level_2_1',
                         level_2_2: 'return_me_level_2_2',
                         level_2_3: 'return_me_level_2_3',
                         level_2_4: {
                           level_3: {
                             level_4_1: 'level_4_1',
                             level_4_2: 'level_4_2',
                           }
                         }
                       },
                       level_1_2: 'level_1_2'
                     },
                     return_me_2: 'return_me_2',
                   }
                 )
          end
        end

        context 'when not equal' do
          it 'raises FailedSpec' do
            spec = {
              return_me_1: Xpect::Keys.new(
                required: {
                  level_1: Xpect::Keys.new(
                    required: {
                      level_2_1: 'level_2_1',
                      level_2_2: lambda {|v| v == 'return_me_level_2_2'},
                      level_2_3: Xpect::Pred.new(
                        pred: lambda {|v| v == 'return_me_level_2_3'}
                      ),
                      level_2_4: {
                        level_3: {
                          level_4_1: 'level_4_1',
                          level_4_2: lambda {|v| v == 'level_4_2'}
                        }
                      }
                    }
                  )
                }
              ),
              return_me_2: 'return_me_2'
            }
            data = {
              return_me_1: {
                level_1: {
                  level_2_1: 'level_2_1',
                  level_2_2: 'return_me_level_2_2',
                  level_2_3: 'return_me_level_2_3',
                  level_2_4: {
                    level_3: {
                      level_4_1: 'level_4_1',
                      level_4_2: 'not_a_match',
                      level_4_3: 'not a required key'
                    }
                  }
                }
              },
              return_me_2: 'return_me_2',
            }

            expect {
              described_class.conform!(spec: spec, data: data)
            }.to raise_error(Xpect::FailedSpec)
          end
        end
      end
    end
  end
end