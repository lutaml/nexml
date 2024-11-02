# lib/moxml/document.rb
module Moxml
  class Document < Node
    def root
      Element.wrap(adapter.root(@native), context)
    end

    def create_element(name)
      Element.new(adapter.create_element(name), context)
    end

    def create_text(content)
      Text.new(adapter.create_text(content), context)
    end

    def create_cdata(content)
      Cdata.new(adapter.create_cdata(content), context)
    end

    def create_comment(content)
      Comment.new(adapter.create_comment(content), context)
    end

    def create_processing_instruction(target, content)
      ProcessingInstruction.new(
        adapter.create_processing_instruction(target, content),
        context
      )
    end

    def create_declaration(version = "1.0", encoding = "UTF-8", standalone = nil)
      decl = adapter.create_declaration(version, encoding, standalone)
      Declaration.new(decl, context)
    end

    def add_child(node)
      node = prepare_node(node)
      if node.is_a?(Declaration)
        if children.empty?
          adapter.add_child(@native, node.native)
        else
          adapter.add_previous_sibling(children.first.native, node.native)
        end
      else
        adapter.add_child(@native, node.native)
      end
      self
    end
  end
end
