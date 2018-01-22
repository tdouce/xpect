module Xpect
  class Keys
    def initialize(required: {}, optional: {})
      raise "required must be a Hash" unless required.is_a?(Hash) && optional.is_a?(Hash)

      @optional = optional
      @required = required
    end

    def conform!(value:, path: [])
      required = process_required(value, path)
      process_optional(required, value, path)
    end

    private

    def process_optional(init, value, path)
      @optional.reduce(init) do |memo, (key, val)|
        if val.is_a?(Keys)
          memo[key] = val.conform!(value: value[key], path: path)
        else
          if value.has_key?(key)
            data_value = value.fetch(key)
            memo[key] = Xpect::Type.process(val, val, data_value, path)
          end
        end

        memo
      end
    end

    def process_required(value, path)
      @required.reduce({}) do |memo, (key, val)|
        if val.is_a?(Keys)
          memo[key] = val.conform!(value: value[key], path: path)
        else
          if value.has_key?(key)
            data_value = value.fetch(key)
            memo[key] = Xpect::Type.process(val, val, data_value, path)
          else
            if val.is_a?(Pred) && val.default
              memo[key] = val.default
            else
              raise FailedSpec, "does not include '#{ key }' at '#{ path }'"
            end
          end
        end

        memo
      end
    end
  end
end
