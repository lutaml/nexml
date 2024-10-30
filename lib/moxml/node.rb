module Moxml
  class Node
    attr_reader :native

    def initialize(native_node = nil)
      @native = native_node || create_native_node
    end

    def self.wrap(native_node)
      return nil if native_node.nil?

      klass = case Moxml.adapter.node_type(native_node)
        when :element then Element
        when :text then Text
        when :cdata then Cdata
        when :comment then Comment
        when :processing_instruction then ProcessingInstruction
        when :document then Document
        when :attribute then Attribute
        when :namespace then Namespace
        else
          raise Error, "Unknown node type: #{native_node.class}"
        end

      klass.new(native_node)
    end

    def parent
      wrap_node(adapter.parent(native))
    end

    def children
      NodeSet.new(adapter.children(native))
    end

    def next_sibling
      wrap_node(adapter.next_sibling(native))
    end

    def previous_sibling
      wrap_node(adapter.previous_sibling(native))
    end

    def remove
      adapter.remove(native)
      self
    end

    def replace(node)
      adapter.replace(native, node.native)
      self
    end

    def add_previous_sibling(node)
      adapter.add_previous_sibling(native, node.native)
      self
    end

    def add_next_sibling(node)
      adapter.add_next_sibling(native, node.native)
      self
    end

    def text
      adapter.text_content(native)
    end

    def text=(content)
      adapter.set_text_content(native, content)
      self
    end

    def inner_html
      adapter.inner_html(native)
    end

    def inner_html=(html)
      adapter.set_inner_html(native, html)
    end

    def outer_html
      adapter.outer_html(native)
    end

    def path
      adapter.path(native)
    end

    def line
      adapter.line(native)
    end

    def column
      adapter.column(native)
    end

    protected

    def wrap_node(native_node)
      self.class.wrap(native_node)
    end

    private

    def adapter
      Moxml.adapter
    end

    def create_native_node
      raise NotImplementedError, "Subclasses must implement create_native_node"
    end
  end
end
