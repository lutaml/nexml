module Moxml
  class Builder
    def initialize(context)
      @context = context
      @current = @document = context.create_document
      @namespaces = {}
    end

    def build(&block)
      instance_eval(&block)
      @document
    end

    def declaration(version: "1.0", encoding: "UTF-8", standalone: nil)
      @document.add_child(
        NodeFactory.create(:declaration, @context, version, encoding, standalone)
      )
    end

    def element(name, attributes = {}, &block)
      el = NodeFactory.create(:element, @context, name)

      attributes.each do |key, value|
        el[key] = value
      end

      @current.add_child(el)

      if block_given?
        previous = @current
        @current = el
        instance_eval(&block)
        @current = previous
      end

      el
    end

    def text(content)
      @current.add_child(NodeFactory.create(:text, @context, content))
    end

    def cdata(content)
      @current.add_child(NodeFactory.create(:cdata, @context, content))
    end

    def comment(content)
      @current.add_child(NodeFactory.create(:comment, @context, content))
    end

    def processing_instruction(target, content)
      @current.add_child(
        NodeFactory.create(:processing_instruction, @context, target, content)
      )
    end

    def namespace(prefix, uri)
      @current.add_namespace(prefix, uri)
      @namespaces[prefix] = uri
    end
  end
end
