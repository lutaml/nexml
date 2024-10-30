module Moxml
  class Attribute < Node
    def initialize(name_or_native = nil, value = nil)
      case name_or_native
      when String
        super(adapter.create_attribute(nil, name_or_native, value))
      else
        super(name_or_native)
      end
    end

    def name
      adapter.attribute_name(native)
    end

    def value
      adapter.attribute_value(native)
    end

    def value=(new_value)
      adapter.set_attribute_value(native, new_value)
    end

    private

    def create_native_node
      adapter.create_attribute(nil, "", "")
    end
  end
end
