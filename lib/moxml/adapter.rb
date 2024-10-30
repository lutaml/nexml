# lib/moxml/adapter.rb
module Moxml
  class Adapter
    # Document operations
    def parse(input, options = {})
      raise NotImplementedError
    end

    def serialize(node, options = {})
      raise NotImplementedError
    end

    # Node type detection
    def node_type(node)
      raise NotImplementedError
    end

    # Node operations
    def node_name(node)
      raise NotImplementedError
    end

    def parent(node)
      raise NotImplementedError
    end

    def children(node)
      raise NotImplementedError
    end

    def next_sibling(node)
      raise NotImplementedError
    end

    def previous_sibling(node)
      raise NotImplementedError
    end

    def document(node)
      raise NotImplementedError
    end

    def remove(node)
      raise NotImplementedError
    end

    def replace(node, new_node)
      raise NotImplementedError
    end

    # Element operations
    def create_element(document, name)
      raise NotImplementedError
    end

    def attributes(element)
      raise NotImplementedError
    end

    def get_attribute(element, name)
      raise NotImplementedError
    end

    def set_attribute(element, name, value)
      raise NotImplementedError
    end

    def remove_attribute(element, name)
      raise NotImplementedError
    end

    def add_child(element, child)
      raise NotImplementedError
    end

    # Namespace operations
    def namespaces(element)
      raise NotImplementedError
    end

    def add_namespace(element, prefix, uri)
      raise NotImplementedError
    end

    def namespace_prefix(namespace)
      raise NotImplementedError
    end

    def namespace_uri(namespace)
      raise NotImplementedError
    end

    # Attribute operations
    def attribute_value(attribute)
      raise NotImplementedError
    end

    def set_attribute_value(attribute, value)
      raise NotImplementedError
    end

    def attribute_namespace(attribute)
      raise NotImplementedError
    end

    # Text operations
    def create_text(document, content)
      raise NotImplementedError
    end

    def text_content(text)
      raise NotImplementedError
    end

    def set_text_content(text, content)
      raise NotImplementedError
    end

    # CDATA operations
    def create_cdata(document, content)
      raise NotImplementedError
    end

    # Comment operations
    def create_comment(document, content)
      raise NotImplementedError
    end

    def comment_content(comment)
      raise NotImplementedError
    end

    def set_comment_content(comment, content)
      raise NotImplementedError
    end

    # Processing instruction operations
    def create_processing_instruction(document, target, content)
      raise NotImplementedError
    end

    def processing_instruction_target(pi)
      raise NotImplementedError
    end

    def processing_instruction_content(pi)
      raise NotImplementedError
    end

    def set_processing_instruction_target(pi, target)
      raise NotImplementedError
    end

    def set_processing_instruction_content(pi, content)
      raise NotImplementedError
    end

    # Document specific operations
    def root(document)
      raise NotImplementedError
    end

    protected

    def normalize_options(options)
      {
        encoding: options[:encoding] || "UTF-8",
        indent: options[:indent] || 2,
        xml_declaration: options.fetch(:xml_declaration, true),
        pretty: options.fetch(:pretty, true),
        namespace_declarations: options.fetch(:namespace_declarations, true),
      }
    end
  end
end
