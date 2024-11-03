require_relative "base"

module Moxml
  module Adapter
    class Ox < Base
      class << self
        def parse(xml, options = {})
          native_doc = begin
              doc = ::Ox::Document.new
              doc << ::Ox.parse(xml, {
                mode: :generic,
                effort: options[:strict] ? :strict : :tolerant,
                smart: true,
              })
              doc
            rescue ::Ox::ParseError => e
              raise Moxml::ParseError.new(e.message)
            end

          DocumentBuilder.new(Context.new(:ox)).build(native_doc)
        end

        def create_document
          ::Ox::Document.new
        end

        def create_native_element(name)
          element = ::Ox::Element.new(name)
          element.instance_variable_set(:@attributes, {})
          element
        end

        def create_native_text(content)
          content
        end

        def create_native_cdata(content)
          ::Ox::CData.new(content)
        end

        def create_native_comment(content)
          ::Ox::Comment.new(content)
        end

        def create_native_processing_instruction(target, content)
          inst = ::Ox::Instruction.new(target)
          inst.value = content
          inst
        end

        def create_native_declaration(version, encoding, standalone)
          doc = ::Ox::Document.new
          doc.version = version
          doc.encoding = encoding
          doc.standalone = standalone
          doc
        end

        def create_native_namespace(element, prefix, uri)
          element.attributes ||= {}
          attr_name = prefix ? "xmlns:#{prefix}" : "xmlns"
          element.attributes[attr_name] = uri
          [prefix, uri]
        end

        def set_namespace(element, ns)
          prefix, uri = ns
          element.attributes ||= {}
          attr_name = prefix ? "xmlns:#{prefix}" : "xmlns"
          element.attributes[attr_name] = uri
        end

        def namespace(element)
          return nil unless element.attributes
          xmlns_attr = element.attributes.find { |k, _| k.start_with?("xmlns:") || k == "xmlns" }
          return nil unless xmlns_attr
          prefix = xmlns_attr[0] == "xmlns" ? nil : xmlns_attr[0].sub("xmlns:", "")
          [prefix, xmlns_attr[1]]
        end

        def processing_instruction_target(node)
          node.name
        end

        def node_type(node)
          case node
          when ::Ox::Element then :element
          when String then :text
          when ::Ox::CData then :cdata
          when ::Ox::Comment then :comment
          when ::Ox::Instruction then :processing_instruction
          when ::Ox::Document then :document
          else :unknown
          end
        end

        def node_name(node)
          node.value rescue node.name
        end

        def set_node_name(node, name)
          node.value = name if node.respond_to?(:value=)
          node.name = name if node.respond_to?(:name=)
        end

        def children(node)
          return [] unless node.respond_to?(:nodes)
          node.nodes || []
        end

        def parent(node)
          node.respond_to?(:parent) ? node.parent : nil
        end

        def next_sibling(node)
          return nil unless parent = node.parent
          siblings = parent.nodes
          idx = siblings.index(node)
          idx ? siblings[idx + 1] : nil
        end

        def previous_sibling(node)
          return nil unless parent = node.parent
          siblings = parent.nodes
          idx = siblings.index(node)
          idx && idx > 0 ? siblings[idx - 1] : nil
        end

        def document(node)
          current = node
          while current && current.respond_to?(:parent) && current.parent
            current = current.parent
          end
          current
        end

        def root(document)
          document.nodes&.find { |node| node.is_a?(::Ox::Element) }
        end

        def attributes(element)
          return {} unless element.respond_to?(:attributes) && element.attributes
          element.attributes.reject { |k, _| k.start_with?("xmlns") }
        end

        def set_attribute(element, name, value)
          element.attributes ||= {}
          element.attributes[name.to_s] = value.to_s
        end

        def get_attribute(element, name)
          return nil unless element.respond_to?(:attributes) && element.attributes
          element.attributes[name.to_s]
        end

        def remove_attribute(element, name)
          return unless element.respond_to?(:attributes) && element.attributes
          element.attributes.delete(name.to_s)
        end

        def add_child(element, child)
          element.nodes ||= []
          element.nodes << child
        end

        def add_previous_sibling(node, sibling)
          return unless node.parent
          idx = node.parent.nodes.index(node)
          node.parent.nodes.insert(idx, sibling) if idx
        end

        def add_next_sibling(node, sibling)
          return unless node.parent
          idx = node.parent.nodes.index(node)
          node.parent.nodes.insert(idx + 1, sibling) if idx
        end

        def remove(node)
          return unless node.parent
          node.parent.nodes.delete(node)
        end

        def replace(node, new_node)
          return unless node.parent
          idx = node.parent.nodes.index(node)
          node.parent.nodes[idx] = new_node if idx
        end

        def text_content(node)
          node.is_a?(String) ? node : node.value.to_s
        end

        def set_text_content(node, content)
          if node.is_a?(String)
            node.replace(content.to_s)
          else
            node.value = content.to_s
          end
        end

        def cdata_content(node)
          node.value.to_s
        end

        def set_cdata_content(node, content)
          node.value = content.to_s
        end

        def comment_content(node)
          node.value.to_s
        end

        def set_comment_content(node, content)
          node.value = content.to_s
        end

        def processing_instruction_content(node)
          node.value.to_s
        end

        def set_processing_instruction_content(node, content)
          node.value = content.to_s
        end

        def namespace_definitions(node)
          return [] unless node.respond_to?(:attributes) && node.attributes
          node.attributes.each_with_object([]) do |(name, value), namespaces|
            next unless name.start_with?("xmlns")
            prefix = name == "xmlns" ? nil : name.sub("xmlns:", "")
            namespaces << [prefix, value]
          end
        end

        def xpath(node, expression, namespaces = {})
          # Ox doesn't support XPath, implement basic path matching
          results = []
          traverse(node) do |n|
            results << n if matches_xpath?(n, expression, namespaces)
          end
          results
        end

        def at_xpath(node, expression, namespaces = {})
          traverse(node) do |n|
            return n if matches_xpath?(n, expression, namespaces)
          end
          nil
        end

        def serialize(node, options = {})
          ::Ox.dump(node,
                    indent: options[:indent] || -1,
                    with_xml: true,
                    with_instructions: true,
                    encoding: options[:encoding])
        end

        private

        def traverse(node, &block)
          return unless node
          yield node
          return unless node.respond_to?(:nodes)
          node.nodes&.each { |child| traverse(child, &block) }
        end

        def matches_xpath?(node, expression, namespaces)
          # Basic XPath matching - enhance as needed
          case expression
          when %r{//(\w+)}
            node.is_a?(::Ox::Element) && node.name == $1
          when %r{//(\w+)\[@(\w+)='([^']+)'\]}
            node.is_a?(::Ox::Element) &&
              node.name == $1 &&
              node.attributes&.[]($2) == $3
          else
            false
          end
        end
      end
    end
  end
end
