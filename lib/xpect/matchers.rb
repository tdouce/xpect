module Xpect
  class Matchers
    def self.anything
      lambda {|_| true }
    end

    def self.nil
      lambda do |val|
        unless val.nil?
          raise_error("'#{ val }' is not nil.")
        end

        true
      end
    end

    def self.falsy
      lambda do |val|
        unless val.nil? || val.empty?
          raise_error("'#{ val }' is not falsy.")
        end

        true
      end
    end

    def self.truthy
      lambda do |val|
        if val.is_a?(Integer) || val.is_a?(Float)
          return true
        end

        if val.nil? || val.empty?
          raise_error("'#{ val }' is not truthy.")
        end

        true
      end
    end

    def self.raise_error(msg)
      raise FailedSpec, msg
    end
  end
end