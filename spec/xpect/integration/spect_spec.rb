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