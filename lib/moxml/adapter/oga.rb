require_relative "base"

module Moxml
  module Adapter
    class Oga < Base
      def self.parse(xml, options = {})
        ::Oga.parse_xml(xml, strict: options[:strict])
      rescue ::Oga::ParseError => e
        raise Moxml::ParseError.new(e.message)
      end

      def self.create_document
        ::Oga::XML::Document.new
      end

      def self.create_element(name)
        ::Oga::XML::Element.new(name: name)
      end

      def self.create_text(content)
        ::Oga::XML::Text.new(text: content.to_s)
      end

      def self.create_cdata(content)
        ::Oga::XML::Cdata.new(text: content.to_s)
      end

      def self.create_comment(content)
        ::Oga::XML::Comment.new(text: content.to_s)
      end

      def self.create_processing_instruction(target, content)
        ::Oga::XML::ProcessingInstruction.new(name: target.to_s, text: content.to_s)
      end

      def self.create_namespace(prefix, uri)
        ::Oga::XML::Namespace.new(name: prefix.to_s, uri: uri.to_s)
      end

      def self.serialize(node, options = {})
        Dumper.new(node, indent: options[:indent]).dump.out
      end

      def self.node_name(node)
        node.name
      end

      def self.node_type(node)
        case node
        when ::Oga::XML::Element then :element
        when ::Oga::XML::Text then :text
        when ::Oga::XML::Cdata then :cdata
        when ::Oga::XML::Comment then :comment
        when ::Oga::XML::ProcessingInstruction then :processing_instruction
        when ::Oga::XML::Document then :document
        else :unknown
        end
      end

      def self.children(node)
        length = node.children.length
        preserve_last = true

        node.children.map.with_index do |child, idx|
          if preserve_last && idx == length - 1 && child.is_a?(::Oga::XML::Text)
            child.text
          elsif child.is_a?(::Oga::XML::Text)
            from_us = child.instance_variable_get(:@from_moxml)
            !from_us && child.text.strip.empty? ? nil : child.text
          else
            preserve_last = false
            child
          end
        end.compact
      end

      def self.parent(node)
        node.parent
      end

      def self.previous_sibling(node)
        node.previous
      end

      def self.next_sibling(node)
        node.next
      end

      def self.document(node)
        node.document
      end

      def self.root(document)
        document.children.first
      end

      def self.attributes(element)
        element.attributes.to_h do |attr|
          [attr.name, attr.value]
        end
      end

      def self.set_attribute(element, name, value)
        attr = ::Oga::XML::Attribute.new(name: name.to_s)
        attr.element = element
        attr.instance_variable_set(:@value, encode_entities(value.to_s, true))
        attr.instance_variable_set(:@decoded, true)
        element.attributes << attr
      end

      def self.get_attribute(element, name)
        element.attribute(name.to_s)&.value
      end

      def self.remove_attribute(element, name)
        element.unset(name.to_s)
      end

      def self.add_child(element, child)
        case child
        when String
          text = create_text(child)
          text.instance_variable_set(:@from_moxml, true)
          element.children << text
        else
          element.children << child
        end
      end

      def self.add_previous_sibling(node, sibling)
        node.before(sibling)
      end

      def self.add_next_sibling(node, sibling)
        node.after(sibling)
      end

      def self.xpath(node, expression, namespaces = {})
        node.xpath(expression)
      end

      def self.at_xpath(node, expression, namespaces = {})
        node.at_xpath(expression)
      end

      # lib/moxml/adapter/oga.rb - Add these implementations
      def self.declaration_version(node)
        node.version
      end

      def self.declaration_encoding(node)
        node.encoding
      end

      def self.declaration_standalone(node)
        node.standalone
      end

      def self.set_declaration_version(node, version)
        valid_versions = ["1.0", "1.1"]
        raise ArgumentError, "Invalid XML version: #{version}" unless valid_versions.include?(version)
        node.version = version
      end

      def self.set_declaration_encoding(node, encoding)
        node.encoding = encoding&.upcase
      end

      def self.set_declaration_standalone(node, standalone)
        valid_values = [nil, "yes", "no"]
        raise ArgumentError, "Invalid standalone value: #{standalone}" unless valid_values.include?(standalone)
        node.standalone = standalone
      end

      def self.namespace_definitions(node)
        node.namespaces.to_a
      end

      def self.set_namespace(node, namespace)
        node.namespace = namespace
      end

      def self.inner_html(node)
        Dumper.new(node).dump.out
      end

      def self.replace_children(node, children)
        node.children.clear
        children.each { |child| node.children << child }
      end

      class Dumper
        def initialize(tree, indent: nil)
          @tree = tree
          @indent = indent
          @depth = 0
          @out = ""
        end

        def dump
          process_node(@tree)
          self
        end

        attr_reader :out

        private

        def process_node(node)
          case node
          when ::Oga::XML::Element
            dump_element(node)
          when ::Oga::XML::Text
            @out += encode_entities(node.text)
          when ::Oga::XML::Comment
            line_break
            @out += "<!--#{node.text}-->"
          when ::Oga::XML::Cdata
            line_break
            @out += "<![CDATA[#{node.text}]]>"
          when ::Oga::XML::ProcessingInstruction
            line_break
            @out += "<?#{node.name} #{node.text}?>"
          when String
            @out += encode_entities(node)
          end
        end

        def dump_element(element)
          attrs = dump_attributes(element)
          line_break

          if element.children.empty?
            @out += "<#{element.name}#{attrs}/>"
          else
            @out += "<#{element.name}#{attrs}>"
            @depth += 1
            element.children.each { |child| process_node(child) }
            @depth -= 1
            line_break unless element.children.last.is_a?(::Oga::XML::Text)
            @out += "</#{element.name}>"
          end
        end

        def dump_attributes(element)
          element.attributes.map do |attr|
            name = attr.namespace ? "#{attr.namespace.name}:#{attr.name}" : attr.name
            %{ #{name}="#{encode_entities(attr.value, true)}"}
          end.join
        end

        def line_break
          @out += "\n"
          @out += " " * (@indent * @depth) if @indent
        end

        def encode_entities(text, attr = false)
          Moxml::Adapter::Base.encode_entities(text, attr)
        end
      end
    end
  end
end
