# lib/moxml/node.rb
module Moxml
  class Node
    attr_reader :native, :context

    def initialize(native, context)
      @native = native
      @context = context
    end

    def document
      Document.wrap(adapter.document(@native), context)
    end

    def parent
      Node.wrap(adapter.parent(@native), context)
    end

    def children
      NodeSet.new(adapter.children(@native), context)
    end

    def next_sibling
      Node.wrap(adapter.next_sibling(@native), context)
    end

    def previous_sibling
      Node.wrap(adapter.previous_sibling(@native), context)
    end

    def add_child(node)
      node = prepare_node(node)
      adapter.add_child(@native, node.native)
      self
    end

    def add_previous_sibling(node)
      node = prepare_node(node)
      adapter.add_previous_sibling(@native, node.native)
      self
    end

    def add_next_sibling(node)
      node = prepare_node(node)
      adapter.add_next_sibling(@native, node.native)
      self
    end

    def remove
      adapter.remove(@native)
      self
    end

    def replace(node)
      node = prepare_node(node)
      adapter.replace(@native, node.native)
      self
    end

    def ==(other)
      self.class == other.class && @native == other.native
    end

    def to_xml(options = {})
      adapter.serialize(@native, default_options.merge(options))
    end

    def xpath(expression, namespaces = {})
      NodeSet.new(adapter.xpath(@native, expression, namespaces), context)
    end

    def at_xpath(expression, namespaces = {})
      Node.wrap(adapter.at_xpath(@native, expression, namespaces), context)
    end

    def self.wrap(node, context)
      return nil if node.nil?

      klass = case adapter(context).node_type(node)
        when :element then Element
        when :text then Text
        when :cdata then Cdata
        when :comment then Comment
        when :processing_instruction then ProcessingInstruction
        when :document then Document
        else self
        end

      klass.new(node, context)
    end

    protected

    def adapter
      context.config.adapter
    end

    def self.adapter(context)
      context.config.adapter
    end

    private

    def prepare_node(node)
      case node
      when String
        Text.new(adapter.create_text(node), context)
      when Node
        node
      else
        raise ArgumentError, "Invalid node type: #{node.class}"
      end
    end

    def default_options
      {
        encoding: context.config.default_encoding,
        indent: context.config.default_indent,
      }
    end
  end
end
