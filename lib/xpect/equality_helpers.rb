module Xpect
  class EqualityHelpers
    def self.equal?(val_1, val_2, path)
      unless val_1 == val_2
        raise FailedSpec, "'#{ val_1 }' is not equal to '#{ val_2 }' at '#{ path }'"
      end
    end

    def self.equal_with_proc?(fn, val, path)
      unless fn.call(val)
        raise FailedSpec, "'#{ val }' does not meet expectation at '#{ path }'"
      end
    end
  end
end