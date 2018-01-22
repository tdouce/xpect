module Xpect
  class Type
    def self.process_array(iterable, data, path)
      iterable.map.with_index do |spc, idx|
        Type.process(spc, spc, data[idx], path)
      end
    end

    def self.process(case_item, spec, val, path)
      case case_item
        when Xpect::Every
          case_item.conform!(data: val, path: path)
        when Array
          unless val.is_a?(Array)
            raise(FailedSpec, "'#{ val }' must be an array")
          end

          Type.process_array(spec, val, path)
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
  end
end