module Xpect

  # TODO: Move to helper file
  def self.process_array(iterable, data, path)
    iterable.map.with_index do |spc, idx|
      Xpect.process_type(spc, spc, data[idx], path)
    end
  end

  # TODO: Move to helper file
  def self.process_type(case_item, spec, val, path)
      case case_item
        when Array
          Xpect.process_array(spec, val, path)
        when Hash
          Xpect::Spect.conform!(spec: spec, data: val, path: path)
        when Pred, Keys
          spec.conform!(value: val, path: path)
        when Proc
          Xpect::EqualityHelpers.equal_with_proc?(spec, val, path)
          val
        else
          Xpect::EqualityHelpers.equal?(spec, val, path)
          val
      end
  end

  # TODO:
  #   * Move to own file
  #   * Add tests
  class Every
    def initialize(item_spec)
      @item_spec = item_spec
    end

    def conform!(data:, path: [])
      data.map.with_index do |val, _|
        Xpect.process_type(@item_spec, @item_spec, val, path)
      end
    end
  end

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
                        when Xpect::Every
                          value.conform!(data: data_value, path: path << key)
                        when Array
                          unless data_value.is_a?(Array)
                            raise(FailedSpec, "'#{ data_value }' must be an array")
                          end

                          Xpect.process_array(value, data_value, path)
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
