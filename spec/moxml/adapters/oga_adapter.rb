# lib/moxml/adapters/oga_adapter.rb
module Moxml
  class OgaAdapter < Adapter
    def parse(input, options = {})
      opts = normalize_options(options)
      parse_options = {
        encoding: opts[:encoding],
        strict: opts[:strict],
      }

      case input
      when String
        ::Oga.parse_xml(input, parse_options)
      when IO
        ::Oga.parse_xml(input.read, parse_options)
      else
        raise ArgumentError, "Input must be String or IO"
      end
    rescue ::Oga::ParseError => e
      raise ParseError.new(e.message)
    end

    def serialize(node, options = {})
      opts = normalize_options(options)
      node.to_xml(
        indent: opts[:indent],
        encoding: opts[:encoding],
        xml_declaration: opts[:xml_declaration],
      )
    end

    def node_type(node)
      case node
      when ::Oga::XML::Element then :element
      when ::Oga::XML::Text then :text
      when ::Oga::XML::Cdata then :cdata
      when ::Oga::XML::Comment then :comment
      when ::Oga::XML::ProcessingInstruction then :processing_instruction
      when ::Oga::XML::Document then :document
      when ::Oga::XML::Attribute then :attribute
      when ::Oga::XML::Namespace then :namespace
      else :unknown
      end
    end

    def create_document
      ::Oga::XML::Document.new
    end

    def create_element(document, name)
      ::Oga::XML::Element.new(name: name)
    end

    def create_text(document, content)
      ::Oga::XML::Text.new(text: content)
    end

    def create_cdata(document, content)
      ::Oga::XML::Cdata.new(text: content)
    end

    def create_comment(document, content)
      ::Oga::XML::Comment.new(text: content)
    end

    def create_processing_instruction(document, target, content)
      ::Oga::XML::ProcessingInstruction.new(name: target, text: content)
    end

    def create_attribute(element, name, value)
      ::Oga::XML::Attribute.new(name: name, value: value)
    end

    def create_namespace(element, prefix, uri)
      ::Oga::XML::Namespace.new(name: prefix, uri: uri)
    end

    def root(document)
      document.children.find { |node| node.is_a?(::Oga::XML::Element) }
    end

    def parent(node)
      node.parent
    end

    def children(node)
      node.children
    end

    def attributes(element)
      element.attributes.each_with_object({}) do |attr, hash|
        hash[attr.name] = attr
      end
    end

    def get_attribute(element, name)
      element.attribute(name)
    end

    def set_attribute(element, name, value)
      if attr = element.attribute(name)
        attr.value = value
      else
        element.set(name, value)
      end
    end

    def remove_attribute(element, name)
      element.unset(name)
    end

    def attribute_name(attr)
      attr.name
    end

    def attribute_value(attr)
      attr.value
    end

    def set_attribute_value(attr, value)
      attr.value = value
    end

    def attribute_namespace(attr)
      attr.namespace
    end

    def namespace_prefix(namespace)
      namespace.name
    end

    def namespace_uri(namespace)
      namespace.uri
    end

    def text_content(node)
      node.text
    end

    def set_text_content(node, content)
      node.text = content
    end

    def add_child(element, child)
      element.children << child
    end

    def remove(node)
      node.remove
    end

    def replace(old_node, new_node)
      old_node.replace(new_node)
    end

    def xpath(node, expression, namespaces = {})
      node.xpath(expression, namespaces)
    end

    def css(node, selector)
      node.css(selector)
    end
  end
end
