# lib/moxml/attribute.rb
module Moxml
  class Attribute < Node
    attr_reader :name, :value

    def initialize(name, value, context)
      @name = name
      @value = value
      @context = context
      # No @native needed for attributes since they're handled differently
    end

    def name=(new_name)
      @name = new_name
    end

    def value=(new_value)
      @value = normalize_xml_value(new_value)
    end

    def namespace
      nil # Implement namespace handling if needed
    end

    def namespace=(ns)
      # Implement namespace setting if needed
    end

    def remove
      # Remove from parent element if needed
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

    protected

    def adapter
      context.config.adapter
    end
  end
end
