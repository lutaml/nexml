module Moxml
  class Comment < Node
    def initialize(content_or_native = nil)
      case content_or_native
      when String
        super(adapter.create_comment(nil, content_or_native))
      else
        super(content_or_native)
      end
    end

    def content
      adapter.comment_content(native)
    end

    def content=(text)
      adapter.set_comment_content(native, text)
      self
    end

    def blank?
      content.strip.empty?
    end

    def comment?
      true
    end

    private

    def create_native_node
      adapter.create_comment(nil, "")
    end
  end
end
