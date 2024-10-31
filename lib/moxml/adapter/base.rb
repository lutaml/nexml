require_relative "entity_encoder"

module Moxml
  module Adapter
    class Base
      def self.parse(xml, options = {})
        raise NotImplementedError
      end

      def self.create_document
        raise NotImplementedError
      end

      def self.create_element(name)
        raise NotImplementedError
      end

      def self.create_text(content)
        raise NotImplementedError
      end

      def self.create_cdata(content)
        raise NotImplementedError
      end

      def self.create_comment(content)
        raise NotImplementedError
      end

      def self.create_processing_instruction(target, content)
        raise NotImplementedError
      end

      def self.create_declaration(version, encoding, standalone)
        raise NotImplementedError
      end

      def self.create_namespace(prefix, uri)
        raise NotImplementedError
      end

      def self.serialize(node, options = {})
        raise NotImplementedError
      end

      def self.node_name(node)
        raise NotImplementedError
      end

      def self.node_type(node)
        raise NotImplementedError
      end

      def self.children(node)
        raise NotImplementedError
      end

      def self.parent(node)
        raise NotImplementedError
      end

      def self.previous_sibling(node)
        raise NotImplementedError
      end

      def self.next_sibling(node)
        raise NotImplementedError
      end

      def self.document(node)
        raise NotImplementedError
      end

      def self.root(document)
        raise NotImplementedError
      end

      def self.attributes(element)
        raise NotImplementedError
      end

      def self.set_attribute(element, name, value)
        raise NotImplementedError
      end

      def self.get_attribute(element, name)
        raise NotImplementedError
      end

      def self.remove_attribute(element, name)
        raise NotImplementedError
      end

      def self.add_child(element, child)
        raise NotImplementedError
      end

      def self.add_previous_sibling(node, sibling)
        raise NotImplementedError
      end

      def self.add_next_sibling(node, sibling)
        raise NotImplementedError
      end

      def self.xpath(node, expression, namespaces = {})
        raise NotImplementedError
      end

      def self.at_xpath(node, expression, namespaces = {})
        raise NotImplementedError
      end

      def self.declaration_version(node)
        raise NotImplementedError
      end

      def self.declaration_encoding(node)
        raise NotImplementedError
      end

      def self.declaration_standalone(node)
        raise NotImplementedError
      end

      def self.set_declaration_version(node, version)
        raise NotImplementedError
      end

      def self.set_declaration_encoding(node, encoding)
        raise NotImplementedError
      end

      def self.set_declaration_standalone(node, standalone)
        raise NotImplementedError
      end

      def self.namespace_definitions(node)
        raise NotImplementedError
      end

      def self.set_namespace(node, namespace)
        raise NotImplementedError
      end

      def self.inner_html(node)
        raise NotImplementedError
      end

      def self.replace_children(node, children)
        raise NotImplementedError
      end

      # Validation methods
      def self.validate_node_type(node, expected_type)
        actual_type = node_type(node)
        unless actual_type == expected_type
          raise ValidationError, "Expected #{expected_type} node, got #{actual_type}"
        end
      end

      def self.validate_name(name)
        unless name.is_a?(String) && name.match?(/^[a-zA-Z_][\w\-\.]*$/)
          raise ValidationError, "Invalid XML name: #{name}"
        end
      end

      def self.validate_encoding(encoding)
        valid_encodings = Encoding.list.map(&:to_s)
        unless encoding.nil? || valid_encodings.include?(encoding.to_s.upcase)
          raise ValidationError, "Invalid encoding: #{encoding}"
        end
      end

      def self.validate_uri(uri)
        uri = uri.to_s
        unless uri.empty? || uri.match?(/\A[a-zA-Z][a-zA-Z0-9+\-.]*:|#\w+\z/)
          raise ValidationError, "Invalid URI: #{uri}"
        end
      end

      def self.validate_prefix(prefix)
        return if prefix.nil?
        unless prefix.is_a?(String) && prefix.match?(/^[a-zA-Z_][\w\-]*$/)
          raise ValidationError, "Invalid namespace prefix: #{prefix}"
        end
      end

      # Helper methods
      def self.normalize_name(name)
        name.to_s.strip
      end

      def self.normalize_prefix(prefix)
        prefix&.to_s&.strip
      end

      def self.normalize_uri(uri)
        uri.to_s.strip
      end

      def self.normalize_encoding(encoding)
        encoding&.to_s&.upcase
      end

      def self.normalize_version(version)
        version.to_s.strip
      end

      def self.normalize_standalone(standalone)
        case standalone
        when true, "true", "yes" then "yes"
        when false, "false", "no" then "no"
        when nil, "" then nil
        else
          raise ValidationError, "Invalid standalone value: #{standalone}"
        end
      end

      def self.normalize_boolean(value)
        case value
        when true, "true", "1", 1 then true
        when false, "false", "0", 0 then false
        else
          raise ValidationError, "Invalid boolean value: #{value}"
        end
      end

      def self.escape_attribute(value)
        encode_entities(value.to_s, true)
      end

      def self.escape_text(value)
        encode_entities(value.to_s, false)
      end

      def self.escape_comment(value)
        value.to_s.gsub(/--/, "- -")
      end

      def self.escape_cdata(value)
        value.to_s.gsub(/\]\]>/, "]]]]><![CDATA[>")
      end

      def self.escape_pi_content(value)
        value.to_s.gsub(/\?>/, "? >")
      end

      # Content type checks
      def self.text?(node)
        node_type(node) == :text
      end

      def self.cdata?(node)
        node_type(node) == :cdata
      end

      def self.comment?(node)
        node_type(node) == :comment
      end

      def self.element?(node)
        node_type(node) == :element
      end

      def self.document?(node)
        node_type(node) == :document
      end

      def self.processing_instruction?(node)
        node_type(node) == :processing_instruction
      end

      def self.has_children?(node)
        children(node).any?
      end

      def self.has_attributes?(node)
        element?(node) && attributes(node).any?
      end

      def self.has_namespace?(node)
        element?(node) && !namespace_definitions(node).empty?
      end

      # Path helpers
      def self.path_to(node)
        path = []
        current = node
        while current && !document?(current)
          if element?(current)
            idx = siblings_before(current).count { |n| node_name(n) == node_name(current) } + 1
            path.unshift("#{node_name(current)}[#{idx}]")
          end
          current = parent(current)
        end
        "/" + path.join("/")
      end

      def self.siblings_before(node)
        return [] unless parent = parent(node)
        siblings = children(parent)
        idx = siblings.index(node)
        idx ? siblings[0...idx] : []
      end

      def self.siblings_after(node)
        return [] unless parent = parent(node)
        siblings = children(parent)
        idx = siblings.index(node)
        idx ? siblings[(idx + 1)..-1] : []
      end

      def self.each_child(node)
        return enum_for(:each_child, node) unless block_given?
        children(node).each { |child| yield child }
      end

      def self.each_attribute(node)
        return enum_for(:each_attribute, node) unless block_given?
        return unless element?(node)
        attributes(node).each { |name, value| yield name, value }
      end

      def self.each_namespace(node)
        return enum_for(:each_namespace, node) unless block_given?
        return unless element?(node)
        namespace_definitions(node).each { |ns| yield ns }
      end

      protected

      def self.encode_entities(text, attr = false)
        text.to_s.gsub(/[&<>'"]/) do |match|
          case match
          when "&" then "&amp;"
          when "<" then "&lt;"
          when ">" then "&gt;"
          when "'" then attr ? "&apos;" : "'"
          when '"' then attr ? "&quot;" : '"'
          end
        end
      end

      def self.decode_entities(text)
        text.to_s.gsub(/&(?:#([0-9]+)|#x([0-9a-fA-F]+)|([0-9a-zA-Z]+));/) do
          if $1
            [$1.to_i].pack("U")
          elsif $2
            [$2.to_i(16)].pack("U")
          else
            case $3
            when "amp" then "&"
            when "lt" then "<"
            when "gt" then ">"
            when "quot" then '"'
            when "apos" then "'"
            else "&#{$3};"
            end
          end
        end
      end
    end
  end
end
