module Moxml
  class Text < Node
    def content
      adapter.text_content(@native)
    end

    def content=(text)
      adapter.set_text_content(@native, normalize_xml_value(text))
      self
    end

    def text?
      true
    end
  end
end
