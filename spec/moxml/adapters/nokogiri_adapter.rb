# lib/moxml/adapters/nokogiri_adapter.rb
module Moxml
  class NokogiriAdapter < Adapter
    def parse(input, options = {})
      opts = normalize_options(options)
      case input
      when String
        ::Nokogiri::XML(input, nil, opts[:encoding], strict: opts[:strict])
      when IO
        ::Nokogiri::XML(input, nil, opts[:encoding], strict: opts[:strict])
      else
        raise ArgumentError, "Input must be String or IO"
      end
    rescue ::Nokogiri::XML::SyntaxError => e
      raise ParseError.new(e.message, line: e.line, column: e.column)
    end

    def serialize(node, options = {})
      opts = normalize_options(options)
      node.to_xml(
        encoding: opts[:encoding],
        indent: opts[:indent],
        save_with: serialize_options(opts),
      )
    end

    def node_type(node)
      case node
      when ::Nokogiri::XML::Element then :element
      when ::Nokogiri::XML::Text then :text
      when ::Nokogiri::XML::CDATA then :cdata
      when ::Nokogiri::XML::Comment then :comment
      when ::Nokogiri::XML::ProcessingInstruction then :processing_instruction
      when ::Nokogiri::XML::Document then :document
      when ::Nokogiri::XML::Attr then :attribute
      when ::Nokogiri::XML::Namespace then :namespace
      else :unknown
      end
    end

    def create_document
      ::Nokogiri::XML::Document.new
    end

    def create_element(document, name)
      doc = document || create_document
      doc.create_element(name)
    end

    def create_text(document, content)
      doc = document || create_document
      doc.create_text_node(content)
    end

    def create_cdata(document, content)
      doc = document || create_document
      doc.create_cdata(content)
    end

    def create_comment(document, content)
      doc = document || create_document
      doc.create_comment(content)
    end

    def create_processing_instruction(document, target, content)
      doc = document || create_document
      doc.create_processing_instruction(target, content)
    end

    def create_attribute(element, name, value)
      attr = ::Nokogiri::XML::Attr.new(
        element || create_document,
        name,
        value
      )
      attr.value = value if value
      attr
    end

    def create_namespace(element, prefix, uri)
      element ||= create_element(nil, "tmp")
      element.add_namespace(prefix, uri)
    end

    def root(document)
      document.root
    end

    def parent(node)
      node.parent
    end

    def children(node)
      node.children
    end

    def attributes(element)
      element.attributes
    end

    def get_attribute(element, name)
      element.attribute(name)
    end

    def set_attribute(element, name, value)
      element[name] = value
    end

    def remove_attribute(element, name)
      element.remove_attribute(name)
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
      namespace.prefix
    end

    def namespace_uri(namespace)
      namespace.href
    end

    def add_namespace(element, prefix, uri)
      element.add_namespace(prefix, uri)
    end

    def text_content(node)
      node.content
    end

    def set_text_content(node, content)
      node.content = content
    end

    def add_child(element, child)
      element.add_child(child)
    end

    def remove(node)
      node.remove
    end

    def replace(old_node, new_node)
      old_node.replace(new_node)
    end

    def inner_html(node)
      node.inner_html
    end

    def set_inner_html(node, html)
      node.inner_html = html
    end

    def add_previous_sibling(node, other)
      node.add_previous_sibling(other)
    end

    def add_next_sibling(node, other)
      node.add_next_sibling(other)
    end

    def xpath(node, expression, namespaces = {})
      node.xpath(expression, namespaces)
    end

    def css(node, selector)
      node.css(selector)
    end

    private

    def serialize_options(opts)
      flags = ::Nokogiri::XML::Node::SaveOptions::AS_XML
      flags |= ::Nokogiri::XML::Node::SaveOptions::FORMAT if opts[:pretty]
      flags |= ::Nokogiri::XML::Node::SaveOptions::NO_DECLARATION unless opts[:xml_declaration]
      flags
    end
  end
end
