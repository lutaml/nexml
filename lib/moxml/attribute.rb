# lib/moxml/attribute.rb
module Moxml
  class Attribute < Node
    def name
      @name ||= adapter.attribute_name(@native)
    end

    def name=(new_name)
      @name = new_name
      adapter.set_attribute_name(@native, new_name)
    end

    def value
      adapter.attribute_value(@native)
    end

    def value=(new_value)
      adapter.set_attribute_value(@native, new_value)
    end

    def namespace
      ns = adapter.attribute_namespace(@native)
      ns ? Namespace.new(ns, context) : nil
    end

    def namespace=(ns)
      adapter.set_attribute_namespace(@native, ns&.native)
    end

    def remove
      adapter.remove_attribute(@native)
      self
    end

    def ==(other)
      return false unless other.is_a?(Attribute)
      name == other.name && value == other.value && namespace == other.namespace
    end

    def to_s
      if namespace && namespace.prefix
        "#{namespace.prefix}:#{name}=\"#{value}\""
      else
        "#{name}=\"#{value}\""
      end
    end

    def attribute?
      true
    end
  end
end
