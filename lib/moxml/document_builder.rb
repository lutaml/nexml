# lib/moxml/document_builder.rb
module Moxml
  class DocumentBuilder
    attr_reader :context

    def initialize(context)
      @context = context
      @node_stack = []
    end

    def build(native_doc)
      @current_doc = Document.new(native_doc, context)
      visit(native_doc)
      @current_doc
    end

    private

    def visit(node)
      method_name = "visit_#{node_type(node)}"
      if respond_to?(method_name, true)
        send(method_name, node)
      end
    end

    def visit_document(node)
      @node_stack.push(@current_doc)
      visit_children(node)
      @node_stack.pop
    end

    def visit_element(node)
      element = Element.new(node, context)
      if @node_stack.empty?
        @current_doc.add_child(element)
      else
        @node_stack.last.add_child(element)
      end
      @node_stack.push(element)
      visit_children(node)
      @node_stack.pop
    end

    def visit_text(node)
      @node_stack.last.add_child(Text.new(node, context)) if @node_stack.any?
    end

    def visit_cdata(node)
      @node_stack.last.add_child(Cdata.new(node, context)) if @node_stack.any?
    end

    def visit_comment(node)
      @node_stack.last.add_child(Comment.new(node, context)) if @node_stack.any?
    end

    def visit_processing_instruction(node)
      @node_stack.last.add_child(ProcessingInstruction.new(node, context)) if @node_stack.any?
    end

    def visit_children(node)
      children(node).each { |child| visit(child) }
    end

    def node_type(node)
      context.config.adapter.node_type(node)
    end

    def children(node)
      context.config.adapter.children(node)
    end
  end
end
