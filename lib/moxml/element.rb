# lib/moxml/element.rb
module Moxml
  class Element < Node
    def name
      adapter.node_name(@native)
    end

    def name=(value)
      adapter.set_node_name(@native, value)
    end

    def []=(name, value)
      adapter.set_attribute(@native, name, value)
    end

    def [](name)
      adapter.get_attribute(@native, name)
    end

    def attributes
      adapter.attributes(@native)
    end

    def remove_attribute(name)
      adapter.remove_attribute(@native, name)
    end

    def add_namespace(prefix, uri)
      adapter.create_namespace(@native, prefix, uri)
      self
    end

    def namespaces
      adapter.namespace_definitions(@native).map do |ns|
        Namespace.new(ns, context)
      end
    end

    def namespace
      ns = adapter.namespace(@native)
      ns ? Namespace.new(ns, context) : nil
    end

    def namespace=(ns)
      adapter.set_namespace(@native, ns&.native)
    end

    def text
      adapter.text_content(@native)
    end

    def text=(content)
      adapter.set_text_content(@native, content)
      self
    end

    def inner_html
      adapter.inner_html(@native)
    end

    def inner_html=(html)
      doc = context.parse("<root>#{html}</root>")
      adapter.replace_children(@native, doc.root.children.map(&:native))
      self
    end

    def attributes
      adapter.attributes(@native).map do |name, native_attr|
        Attribute.new(native_attr, context)
      end
    end

    def attribute(name)
      native_attr = adapter.get_attribute(@native, name)
      native_attr ? Attribute.new(native_attr, context) : nil
    end

    def []=(name, value)
      if value.nil?
        remove_attribute(name)
      else
        adapter.set_attribute(@native, name, value)
      end
    end

    def [](name)
      attr = attribute(name)
      attr&.value
    end
  end
end
