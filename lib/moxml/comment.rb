module Moxml
  class Comment < Node
    def content
      adapter.comment_content(@native)
    end

    def content=(text)
      text = normalize_xml_value(text)
      validate_comment_content(text)
      adapter.set_comment_content(@native, text)
      self
    end

    def comment?
      true
    end

    private

    def validate_comment_content(text)
      if text.start_with?("-") || text.end_with?("-")
        raise ValidationError, "XML comment cannot start or end with a hyphen"
      end

      if text.include?("--")
        raise ValidationError, "XML comment cannot contain double hyphens (--)"
      end
    end
  end
end
