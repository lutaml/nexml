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
      Declaration.new(
        adapter.create_declaration(version, encoding, standalone),
        context
      )
    end
  end
end
