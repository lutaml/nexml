module Moxml
  class Text < Node
    def initialize(content_or_native = nil)
      case content_or_native
      when String
        super(adapter.create_text(nil, content_or_native))
      else
        super(content_or_native)
      end
    end

    def content
      adapter.text_content(native)
    end

    def content=(text)
      adapter.set_text_content(native, text)
      self
    end

    def blank?
      content.strip.empty?
    end

    def cdata?
      false
    end

    def text?
      true
    end

    private

    def create_native_node
      adapter.create_text(nil, "")
    end
  end
end
