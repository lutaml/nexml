module Moxml
  class Document < Node
    def self.parse(input, options = {})
      new(Moxml.adapter.parse(input, options))
    end

    def root
      wrap_node(adapter.root(native))
    end

    def create_element(name)
      Element.new(adapter.create_element(native, name))
    end

    def create_text(content)
      Text.new(adapter.create_text(native, content))
    end

    def create_cdata(content)
      Cdata.new(adapter.create_cdata(native, content))
    end

    def create_comment(content)
      Comment.new(adapter.create_comment(native, content))
    end

    def create_processing_instruction(target, content)
      ProcessingInstruction.new(
        adapter.create_processing_instruction(native, target, content)
      )
    end

    def to_xml(options = {})
      adapter.serialize(native, options)
    end

    def encoding
      declaration&.encoding
    end

    def encoding=(encoding)
      (declaration || add_declaration).encoding = encoding
    end

    def version
      declaration&.version
    end

    def version=(version)
      (declaration || add_declaration).version = version
    end

    def standalone
      declaration&.standalone
    end

    def standalone=(standalone)
      (declaration || add_declaration).standalone = standalone
    end

    def declaration
      children.find { |node| node.is_a?(Declaration) }
    end

    def add_declaration(version = "1.0", encoding = "UTF-8", standalone = nil)
      decl = Declaration.new(version, encoding, standalone)
      if declaration
        declaration.replace(decl)
      else
        add_child(decl)
      end
      decl
    end

    def css(selector)
      NodeSet.new(adapter.css(native, selector))
    end

    def xpath(expression, namespaces = {})
      NodeSet.new(adapter.xpath(native, expression, namespaces))
    end

    def at_css(selector)
      node = adapter.at_css(native, selector)
      node.nil? ? nil : wrap_node(node)
    end

    def at_xpath(expression, namespaces = {})
      node = adapter.at_xpath(native, expression, namespaces)
      node.nil? ? nil : wrap_node(node)
    end

    private

    def create_native_node
      adapter.create_document
    end
  end
end
