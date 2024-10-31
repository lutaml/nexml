# lib/moxml/comment.rb
module Moxml
  class Comment < Node
    def content
      adapter.comment_content(@native)
    end

    def content=(text)
      adapter.set_comment_content(@native, text)
      self
    end

    def comment?
      true
    end
  end
end
