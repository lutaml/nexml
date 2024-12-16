module Moxml
  class Comment < Node
    def content
      adapter.comment_content(@native)
    end

    def content=(text)
      text = normalize_xml_value(text)
      adapter.validate_comment_content(text)
      adapter.set_comment_content(@native, text)
      self
    end

    def comment?
      true
    end
  end
end
