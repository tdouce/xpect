module Xpect
  class Keys
    def initialize(required: {}, optional: {})
      raise "required must be a Hash" unless required.is_a?(Hash) && optional.is_a?(Hash)

      @optional = optional
      @required = required
    end

    # Return only what is specified in spec?
    def conform!(value:, path: [])
      reduced = reduce(enumerable: @required, init: {}, value: value, path: path,
                       when_value_does_not_have_key: lambda do |memo, val, key, path|
                         if val.is_a?(Pred) && val.default
                           memo[key] = val.default
                         else
                           raise FailedSpec, "does not include '#{ key }' at '#{ path }'"
                         end

                         memo
                       end)

      reduce(enumerable: @optional, init: reduced, value: value, path: path)
    end

    private

    def reduce(enumerable:, init:, value:, path:, when_value_does_not_have_key: nil)
      enumerable.reduce(init) do |memo, (key, val)|
        if val.is_a?(Keys)
          memo[key] = val.conform!(value: value[key], path: path)
        else
          if value.has_key?(key)
            data_value = value.fetch(key)
            memo[key] = case val
                          when Hash
                            Xpect::Spect.conform!(spec: val, data: data_value, path: path << key)
                          when Pred
                            val.conform!(value: data_value, path: path << key)
                          when Proc
                            Xpect::EqualityHelpers.equal_with_proc?(val, data_value, path)
                            data_value
                          else
                            Xpect::EqualityHelpers.equal?(data_value, val, path)
                            data_value
                        end
          elsif when_value_does_not_have_key
            memo = when_value_does_not_have_key.call(memo, val, key, path)
          end
        end

        memo
      end
    end
  end
end
