module Xpect
  class Spect
    def self.conform!(spec:, data:, path: [])
      new.conform!(spec: spec, data: data, path: path)
    end

    def self.validate!(spec, data)
      new.validate!(spec, data)
    end

    # 1) Raise exception if spec isn't satisfied
    # 2) Return original data
    def validate!(spec, data)
      call(spec: spec, data: data, init: data)
    end

    # 1) Raise exception if spec isn't satisfied
    # 2) Return data as it adheres to the spec
    def conform!(spec:, data:, path: [])
      call(spec: spec, data: data, path: path)
    end

    private

    def call(spec:, data:, path: [], init: {})
      spec.reduce(init) do |memo, (key, value)|
        unless data.is_a?(Hash)
          raise(FailedSpec, "'#{ data }' is not equal to '#{ value }'")
        end

        path = path << key
        data_value = data[key]
        memo[key] = if !value.is_a?(Hash)
                      case value
                        when Pred, Keys
                          value.conform!(value: data_value, path: path)
                        when Proc
                          Xpect::EqualityHelpers.equal_with_proc?(value, data_value, path)
                          data_value
                        else
                          Xpect::EqualityHelpers.equal?(value, data_value, path)
                          data_value
                      end
                    else
                      call(spec: spec[key], data: data_value, path: path)
                    end

        memo
      end
    end
  end
end
