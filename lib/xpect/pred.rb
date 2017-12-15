require 'xpect/failed_spec'

module Xpect
  class Pred
    attr_reader :default

    def initialize(pred:, error_msg: nil, default: nil)
      unless pred.is_a?(Proc)
        raise "pred must be a Proc"
      end

      @pred = pred
      @error_msg = error_msg
      @default = default
    end

    def conform!(value:, path: nil)
      return @default if @default && value.nil?

      if value.nil?
        raise FailedSpec, "the value at path '#{ path }' is missing"
      end

      unless @pred.call(value)
        error_msg = if @error_msg
                      "'#{ value }' does not meet spec for '#{ path }': '#{ @error_msg }'"
                    else
                      "'#{ value }' does not meet spec for '#{ path }'"
                    end

        raise FailedSpec, error_msg
      end

      value
    end
  end
end