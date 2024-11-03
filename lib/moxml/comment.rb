module Moxml
  class Comment < Node
    def content
      adapter.comment_content(@native)
    end

    def content=(text)
      adapter.set_comment_content(@native, normalize_xml_value(text))
      self
    end

    def comment?
      true
    end
  end
end
