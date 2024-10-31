require_relative "base"

module Moxml
  module Adapter
    class Ox < Base
      def self.parse(xml, options = {})
        parse_options = {
          mode: :generic,
          effort: options[:strict] ? :strict : :tolerant,
          smart: true,
        }
        ::Ox.load(xml, mode: :generic, effort: parse_options[:effort])
      rescue ::Ox::ParseError => e
        raise Moxml::ParseError.new(e.message)
      end

      def self.create_document
        ::Ox::Document.new
      end

      def self.create_element(name)
        element = ::Ox::Element.new(name)
        element.instance_variable_set(:@attributes, {})
        element.instance_variable_set(:@nodes, [])
        element
      end

      def self.create_text(content)
        encode_entities(content.to_s)
      end

      def self.create_cdata(content)
        ::Ox::CData.new(content.to_s)
      end

      def self.create_comment(content)
        ::Ox::Comment.new(content.to_s)
      end

      def self.namespace_uri(namespace)
        namespace.last
      end

      def self.namespace_prefix(namespace)
        prefix = namespace.first
        prefix == "xmlns" ? nil : prefix.sub("xmlns:", "")
      end

      def self.namespace_definitions(node)
        namespaces = []
        if node.respond_to?(:attributes) && node.attributes
          node.attributes.each do |name, value|
            next unless name.start_with?("xmlns")
            prefix = name == "xmlns" ? nil : name.sub("xmlns:", "")
            namespaces << [prefix, value]
          end
        end
        namespaces
      end

      def self.create_processing_instruction(target, content)
        inst = ::Ox::Instruction.new(target.to_s)
        inst.value = content.to_s
        inst
      end

      def self.processing_instruction_target(node)
        node.value
      end

      def self.processing_instruction_content(node)
        node.value
      end

      def self.set_processing_instruction_target(node, target)
        node.value = target.to_s
      end

      def self.set_processing_instruction_content(node, content)
        node.value = content.to_s
      end

      def self.create_namespace(prefix, uri)
        prefix = prefix.to_s
        attr_name = prefix.empty? ? "xmlns" : "xmlns:#{prefix}"
        [attr_name, uri.to_s]
      end

      def self.serialize(node, options = {})
        options = normalize_options(options)
        case node
        when ::Ox::Comment
          "<!-- #{node.value} -->"
        when ::Ox::InstNode
          "<?#{node.name} #{node.value}?>"
        else
          ::Ox.dump(node,
                    indent: options[:indent] || -1,
                    with_xml: options[:xml_declaration],
                    with_instructions: true)
        end
      end

      def self.normalize_options(options)
        {
          indent: 2,
          pretty: true,
          encoding: "UTF-8",
          xml_declaration: true,
        }.merge(options)
      end

      def self.node_name(node)
        node.respond_to?(:name) ? node.name : nil
      end

      def self.node_type(node)
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

      def self.children(node)
        return [] unless node.respond_to?(:nodes)

        nodes = node.nodes || []
        length = nodes.length
        preserve_last = true

        nodes.map.with_index do |child, idx|
          if preserve_last && idx == length - 1 && child.is_a?(String)
            child
          elsif child.is_a?(String)
            child.strip.empty? ? nil : child
          else
            preserve_last = false
            child
          end
        end.compact
      end

      def self.parent(node)
        node.respond_to?(:parent) ? node.parent : nil
      end

      def self.previous_sibling(node)
        return nil unless node.respond_to?(:parent) && node.parent
        siblings = node.parent.nodes
        idx = siblings.index(node)
        idx && idx > 0 ? siblings[idx - 1] : nil
      end

      def self.next_sibling(node)
        return nil unless node.respond_to?(:parent) && node.parent
        siblings = node.parent.nodes
        idx = siblings.index(node)
        idx ? siblings[idx + 1] : nil
      end

      def self.document(node)
        current = node
        while current && current.respond_to?(:parent) && current.parent
          current = current.parent
        end
        current
      end

      def self.root(document)
        children(document).find { |node| node.is_a?(::Ox::Element) }
      end

      def self.attributes(element)
        return {} unless element.respond_to?(:attributes) && element.attributes
        element.attributes.reject { |k, _| k.start_with?("xmlns") }
      end

      def self.set_attribute(element, name, value)
        element.attributes ||= {}
        element.attributes[name.to_s] = encode_entities(value.to_s, true)
      end

      def self.get_attribute(element, name)
        return nil unless element.respond_to?(:attributes) && element.attributes
        element.attributes[name.to_s]
      end

      def self.remove_attribute(element, name)
        return unless element.respond_to?(:attributes) && element.attributes
        element.attributes.delete(name.to_s)
      end

      def self.add_child(element, child)
        element.nodes ||= []
        case child
        when String
          element.nodes << encode_entities(child)
        else
          element.nodes << child
        end
      end

      def self.add_previous_sibling(node, sibling)
        return unless node.parent
        idx = node.parent.nodes.index(node)
        node.parent.nodes.insert(idx, sibling) if idx
      end

      def self.add_next_sibling(node, sibling)
        return unless node.parent
        idx = node.parent.nodes.index(node)
        node.parent.nodes.insert(idx + 1, sibling) if idx
      end

      def self.xpath(node, expression, namespaces = {})
        result = []
        traverse(node) do |n|
          if matches_xpath?(n, expression, namespaces)
            result << n
          end
        end
        result
      end

      def self.at_xpath(node, expression, namespaces = {})
        traverse(node) do |n|
          return n if matches_xpath?(n, expression, namespaces)
        end
        nil
      end

      def self.declaration_version(node)
        node.respond_to?(:version) ? node.version : "1.0"
      end

      def self.declaration_encoding(node)
        node.respond_to?(:encoding) ? node.encoding : "UTF-8"
      end

      def self.declaration_standalone(node)
        node.respond_to?(:standalone) ? node.standalone : nil
      end

      def self.set_declaration_version(node, version)
        valid_versions = ["1.0", "1.1"]
        raise ArgumentError, "Invalid XML version: #{version}" unless valid_versions.include?(version)
        node.instance_variable_set(:@version, version) if node.respond_to?(:version=)
      end

      def self.set_declaration_encoding(node, encoding)
        node.instance_variable_set(:@encoding, encoding&.upcase) if node.respond_to?(:encoding=)
      end

      def self.set_declaration_standalone(node, standalone)
        valid_values = [nil, "yes", "no"]
        raise ArgumentError, "Invalid standalone value: #{standalone}" unless valid_values.include?(standalone)
        node.instance_variable_set(:@standalone, standalone) if node.respond_to?(:standalone=)
      end

      def self.namespace_definitions(node)
        namespaces = []
        if node.respond_to?(:attributes) && node.attributes
          node.attributes.each do |name, value|
            next unless name.start_with?("xmlns")
            prefix = name == "xmlns" ? nil : name.sub("xmlns:", "")
            namespaces << [prefix, value]
          end
        end
        namespaces
      end

      def self.set_namespace(node, namespace)
        return unless node.respond_to?(:attributes) && namespace
        node.attributes ||= {}
        prefix = namespace[0]
        uri = namespace[1]
        attr_name = prefix ? "xmlns:#{prefix}" : "xmlns"
        node.attributes[attr_name] = uri
      end

      def self.inner_html(node)
        return "" unless node.respond_to?(:nodes)
        node.nodes.map { |child| serialize(child) }.join
      end

      def self.replace_children(node, children)
        return unless node.respond_to?(:nodes=)
        node.nodes = children
      end

      private

      def self.traverse(node, &block)
        return unless node
        yield node
        return unless node.respond_to?(:nodes)
        node.nodes&.each { |child| traverse(child, &block) }
      end

      def self.matches_xpath?(node, expression, namespaces)
        # Simple implementation - enhance as needed
        case expression
        when "//child"
          node.is_a?(::Ox::Element) && node.name == "child"
        when /\/\/(\w+)\[@(\w+)='([^']+)'\]/
          element, attr, value = $1, $2, $3
          node.is_a?(::Ox::Element) &&
            node.name == element &&
            node.attributes&.[](attr) == value
        else
          false
        end
      end
    end
  end
end
