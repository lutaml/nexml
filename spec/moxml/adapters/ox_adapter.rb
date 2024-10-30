# lib/moxml/adapters/ox_adapter.rb
module Moxml
  class OxAdapter < Adapter
    def parse(input, options = {})
      opts = normalize_options(options)
      parse_options = {
        mode: :generic,
        effort: opts[:strict] ? :strict : :tolerant,
        smart: true,
      }

      case input
      when String
        ::Ox.parse(input, parse_options)
      when IO
        ::Ox.parse(input.read, parse_options)
      else
        raise ArgumentError, "Input must be String or IO"
      end
    rescue ::Ox::ParseError => e
      raise ParseError.new(e.message)
    end

    def serialize(node, options = {})
      opts = normalize_options(options)
      ::Ox.dump(node,
                indent: opts[:indent],
                with_xml: opts[:xml_declaration],
                encoding: opts[:encoding])
    end

    def node_type(node)
      case node
      when ::Ox::Element then :element
      when String then :text
      when ::Ox::CData then :cdata
      when ::Ox::Comment then :comment
      when ::Ox::InstuctElement then :processing_instruction
      when ::Ox::Document then :document
      else :unknown
      end
    end

    def create_document
      ::Ox::Document.new(version: "1.0")
    end

    def create_element(document, name)
      ::Ox::Element.new(name)
    end

    def create_text(document, content)
      content.to_s
    end

    def create_cdata(document, content)
      ::Ox::CData.new(content)
    end

    def create_comment(document, content)
      ::Ox::Comment.new(content)
    end

    def create_processing_instruction(document, target, content)
      inst = ::Ox::InstuctElement.new(target)
      inst.value = content
      inst
    end

    def create_attribute(element, name, value)
      [name, value]
    end

    def root(document)
      document.locate("*").first
    end

    def parent(node)
      return nil unless node.respond_to?(:parent)
      node.parent
    end

    def children(node)
      return [] unless node.respond_to?(:nodes)
      node.nodes || []
    end

    def attributes(element)
      return {} unless element.respond_to?(:attributes)
      element.attributes || {}
    end

    def get_attribute(element, name)
      return nil unless element.respond_to?(:attributes)
      element.attributes&.[](name)
    end

    def set_attribute(element, name, value)
      element.attributes ||= {}
      element.attributes[name] = value
    end

    def remove_attribute(element, name)
      element.attributes&.delete(name)
    end

    def text_content(node)
      case node
      when String then node
      when ::Ox::CData then node.value
      when ::Ox::Element then node.text
      else nil
      end
    end

    def set_text_content(node, content)
      case node
      when ::Ox::CData
        node.value = content
      when ::Ox::Element
        node.replace_text(content)
      end
    end

    def add_child(element, child)
      element.nodes ||= []
      element.nodes << child
    end

    def remove(node)
      parent = node.parent
      parent.nodes.delete(node) if parent&.nodes
    end

    def replace(old_node, new_node)
      parent = old_node.parent
      return unless parent&.nodes
      index = parent.nodes.index(old_node)
      parent.nodes[index] = new_node if index
    end

    def xpath(node, expression, namespaces = {})
      node.locate(expression)
    end

    def css(node, selector)
      # Ox doesn't support CSS selectors natively
      # You might want to implement CSS to XPath conversion
      raise NotImplementedError, "CSS selectors not supported in Ox adapter"
    end
  end
end
