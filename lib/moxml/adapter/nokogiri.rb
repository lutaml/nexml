require_relative "base"

module Moxml
  module Adapter
    class Nokogiri < Base
      def self.parse(xml, options = {})
        ::Nokogiri::XML(xml) do |config|
          config.strict.nonet
          config.recover unless options[:strict]
        end
      rescue ::Nokogiri::XML::SyntaxError => e
        raise Moxml::ParseError.new(e.message, line: e.line, column: e.column)
      end

      def self.create_document
        ::Nokogiri::XML::Document.new
      end

      def self.create_element(name)
        ::Nokogiri::XML::Element.new(name, ::Nokogiri::XML::Document.new)
      end

      def self.create_text(content)
        text = ::Nokogiri::XML::Text.new(content.to_s, ::Nokogiri::XML::Document.new)
        text.content = escape_text(content.to_s)
        text
      end

      def self.create_cdata(content)
        doc = ::Nokogiri::XML::Document.new
        cdata = doc.create_cdata(content.to_s)
        cdata
      end

      def self.create_processing_instruction(target, content)
        content = content.to_s.gsub(/"/, "&quot;").gsub(/'/, "&apos;")
        ::Nokogiri::XML::ProcessingInstruction.new(
          ::Nokogiri::XML::Document.new,
          target.to_s,
          content
        )
      end

      def self.validate_namespace_uri(uri)
        unless uri.empty? || uri.match?(/\A[a-zA-Z][a-zA-Z0-9+\-.]*:|#\w+\z/)
          raise Moxml::NamespaceError, "Invalid URI: #{uri}"
        end
      end

      def self.create_namespace(element, prefix, uri)
        validate_namespace_uri(uri)
        if prefix&.strip&.empty?
          element.add_namespace(nil, uri)
        else
          element.add_namespace(prefix, uri)
        end
      end

      def self.namespace(node)
        node.namespace
      end

      def self.namespace_prefix(namespace)
        namespace&.prefix
      end

      def self.set_namespace(element, namespace)
        prefix, uri = namespace
        if prefix
          element.add_namespace(prefix, uri)
        else
          element.add_namespace(nil, uri)
        end
      end

      def self.namespace_prefix(namespace)
        namespace&.prefix || ""
      end

      def self.namespace_uri(namespace)
        namespace&.href
      end

      def self.node_name(node)
        node.name
      end

      def self.node_type(node)
        case node
        when ::Nokogiri::XML::Element then :element
        when ::Nokogiri::XML::Text then :text
        when ::Nokogiri::XML::CDATA then :cdata
        when ::Nokogiri::XML::Comment then :comment
        when ::Nokogiri::XML::ProcessingInstruction then :processing_instruction
        when ::Nokogiri::XML::Document then :document
        else :unknown
        end
      end

      def self.children(node)
        # Filter out whitespace-only text nodes except when they're the only child
        all_children = node.children.to_a
        return all_children if all_children.size <= 1

        all_children.reject do |child|
          child.text? && child.content.strip.empty?
        end
      end

      def self.parent(node)
        node.parent
      end

      def self.previous_sibling(node)
        node.previous_sibling
      end

      def self.next_sibling(node)
        node.next_sibling
      end

      def self.document(node)
        node.document
      end

      def self.root(document)
        document.root
      end

      def self.attributes(element)
        element.attributes.transform_values(&:value)
      end

      def self.set_attribute(element, name, value)
        element[name.to_s] = escape_attribute(value.to_s)
      end

      def self.get_attribute(element, name)
        attr = element[name.to_s]
        return nil if attr.nil?
        ::Nokogiri::XML::Attr.new(element, name.to_s, attr)
      end

      def self.remove_attribute(element, name)
        element.remove_attribute(name.to_s)
      end

      def self.attribute_name(attr)
        if attr.is_a?(::Nokogiri::XML::Attr)
          attr.name
        else
          attr.to_s
        end
      end

      def self.attribute_value(attr)
        if attr.is_a?(::Nokogiri::XML::Attr)
          attr.value
        else
          attr.to_s
        end
      end

      def self.attribute_namespace(attr)
        attr.is_a?(String) ? nil : attr.namespace
      end

      def self.set_attribute_name(attr, name)
        if attr.is_a?(::Nokogiri::XML::Attr)
          attr.name = name.to_s
        end
      end

      def self.set_attribute_value(attr, value)
        if attr.is_a?(::Nokogiri::XML::Attr)
          attr.value = value.to_s
        end
      end

      def self.set_attribute_namespace(attr, namespace)
        attr.namespace = namespace
      end

      def self.add_child(element, child)
        element.add_child(child)
      end

      def self.add_previous_sibling(node, sibling)
        node.add_previous_sibling(sibling)
      end

      def self.add_next_sibling(node, sibling)
        node.add_next_sibling(sibling)
      end

      def self.xpath(node, expression, namespaces = {})
        node.xpath(expression, namespaces).to_a
      rescue ::Nokogiri::XML::XPath::SyntaxError => e
        raise Moxml::XPathError, e.message
      end

      def self.at_xpath(node, expression, namespaces = {})
        node.at_xpath(expression, namespaces)
      rescue ::Nokogiri::XML::XPath::SyntaxError => e
        raise Moxml::XPathError, e.message
      end

      def self.create_declaration(version = "1.0", encoding = "UTF-8", standalone = nil)
        doc = ::Nokogiri::XML::Document.new
        doc.version = version
        doc.encoding = encoding
        doc.children.first.attributes["standalone"] = standalone if standalone
        doc
      end

      def self.declaration_version(node)
        node.version
      end

      def self.declaration_encoding(node)
        node.encoding
      end

      def self.declaration_standalone(node)
        node.children.first&.attributes&.dig("standalone")&.value
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
        if standalone
          node.children.first.attributes["standalone"] = standalone
        else
          node.children.first.attributes.delete("standalone")
        end
      end

      def self.processing_instruction_target(node)
        node.name
      end

      def self.processing_instruction_content(node)
        node.content.gsub(/&quot;/, '"').gsub(/&apos;/, "'")
      end

      def self.set_processing_instruction_content(node, content)
        content = content.to_s.gsub(/"/, "&quot;").gsub(/'/, "&apos;")
        node.content = content
      end

      def self.set_processing_instruction_target(node, target)
        node.name = target.to_s
      end

      def self.inner_html(node)
        node.inner_html
      end

      def self.replace_children(node, children)
        node.children = ::Nokogiri::XML::NodeSet.new(node.document, children)
      end

      def self.remove(node)
        node.remove
      end

      def self.replace(node, new_node)
        node.replace(new_node)
      end

      def self.escape_text(text)
        text.to_s.gsub(/[&<>'"]/) do |match|
          case match
          when "&" then "&amp;"
          when "<" then "&lt;"
          when ">" then "&gt;"
          when '"' then "&quot;"
          when "'" then "&apos;"
          end
        end
      end

      def self.text_content(node)
        node.content
      end

      def self.set_text_content(node, content)
        node.content = escape_text(content.to_s)
      end

      def self.set_node_name(node, name)
        node.name = name.to_s
      end

      def self.create_comment(content)
        content = content.to_s.gsub(/--/, "- -")
        ::Nokogiri::XML::Comment.new(::Nokogiri::XML::Document.new, content)
      end

      def self.comment_content(node)
        node.content.gsub(/- -/, "--")
      end

      def self.set_comment_content(node, content)
        node.content = content.to_s.gsub(/--/, "- -")
      end

      def self.cdata_content(node)
        node.content
      end

      def self.set_cdata_content(node, content)
        node.content = content.to_s
      end

      def self.serialize(node, options = {})
        options = normalize_options(options)
        case node
        when ::Nokogiri::XML::Comment
          comment = node.content.gsub(/--/, "- -")
          "<!-- #{comment} -->"
        when ::Nokogiri::XML::ProcessingInstruction
          "<?#{node.name} #{node.content}?>"
        else
          if options[:pretty]
            node.to_xml(indent: options[:indent])
          else
            node.to_xml(save_with: ::Nokogiri::XML::Node::SaveOptions::AS_XML)
          end
        end
      end

      private

      def self.normalize_options(options)
        {
          indent: 2,
          pretty: true,
          encoding: "UTF-8",
          xml_declaration: true,
        }.merge(options)
      end
    end
  end
end
