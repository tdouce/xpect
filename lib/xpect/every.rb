module Xpect
  # TODO: Add tests
  class Every
    def initialize(item_spec)
      @item_spec = item_spec
    end

    def conform!(data:, path: [])
      data.map.with_index do |val, _|
        Xpect::Type.process(@item_spec, @item_spec, val, path)
      end
    end
  end
end