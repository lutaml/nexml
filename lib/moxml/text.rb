# lib/moxml/text.rb
module Moxml
  class Text < Node
    def content
      adapter.text_content(@native)
    end

    def content=(text)
      adapter.set_text_content(@native, text)
      self
    end

    def text?
      true
    end
  end
end
