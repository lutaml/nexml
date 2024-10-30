module Moxml
  class Element < Node
    def initialize(name_or_native = nil)
      case name_or_native
      when String
        super(adapter.create_element(nil, name_or_native))
      else
        super(name_or_native)
      end
    end

    def name
      adapter.node_name(native)
    end

    def attributes
      adapter.attributes(native).transform_values { |attr| Attribute.new(attr) }
    end

    def []=(name, value)
      adapter.set_attribute(native, name, value)
    end

    def [](name)
      attr = adapter.get_attribute(native, name)
      attr.nil? ? nil : Attribute.new(attr)
    end

    def add_child(node)
      adapter.add_child(native, node.native)
      self
    end

    def namespace
      ns = adapter.namespace(native)
      ns.nil? ? nil : Namespace.new(ns)
    end

    def namespace=(ns)
      adapter.set_namespace(native, ns&.native)
      self
    end

    def namespaces
      adapter.namespaces(native).transform_values { |ns| Namespace.new(ns) }
    end

    def css(selector)
      NodeSet.new(adapter.css(native, selector))
    end

    def xpath(expression, namespaces = {})
      NodeSet.new(adapter.xpath(native, expression, namespaces))
    end

    def at_css(selector)
      node = adapter.at_css(native, selector)
      node.nil? ? nil : wrap_node(node)
    end

    def at_xpath(expression, namespaces = {})
      node = adapter.at_xpath(native, expression, namespaces)
      node.nil? ? nil : wrap_node(node)
    end

    def blank?
      text.strip.empty? && children.empty?
    end

    def value
      text.strip
    end

    def value=(val)
      self.text = val.to_s
    end

    def matches?(selector)
      adapter.matches?(native, selector)
    end

    def ancestors
      NodeSet.new(adapter.ancestors(native))
    end

    def descendants
      NodeSet.new(adapter.descendants(native))
    end

    def previous_elements
      NodeSet.new(adapter.previous_elements(native))
    end

    def next_elements
      NodeSet.new(adapter.next_elements(native))
    end

    def inner_text
      adapter.inner_text(native)
    end

    def inner_text=(text)
      adapter.set_inner_text(native, text)
      self
    end

    def key?(name)
      adapter.has_attribute?(native, name)
    end

    alias has_attribute? key?

    def classes
      (self["class"] || "").split(/\s+/)
    end

    def add_class(*names)
      self["class"] = (classes + names).uniq.join(" ")
      self
    end

    def remove_class(*names)
      self["class"] = (classes - names).join(" ")
      self
    end

    def toggle_class(name)
      if classes.include?(name)
        remove_class(name)
      else
        add_class(name)
      end
    end

    def has_class?(name)
      classes.include?(name)
    end

    private

    def create_native_node
      adapter.create_element(nil, "")
    end
  end
end
