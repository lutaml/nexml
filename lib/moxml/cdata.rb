module Moxml
  class Cdata < Node
    def initialize(content_or_native = nil)
      case content_or_native
      when String
        super(adapter.create_cdata(nil, content_or_native))
      else
        super(content_or_native)
      end
    end

    def content
      adapter.cdata_content(native)
    end

    def content=(text)
      adapter.set_cdata_content(native, text)
      self
    end

    def blank?
      content.strip.empty?
    end

    def cdata?
      true
    end

    def text?
      false
    end

    private

    def create_native_node
      adapter.create_cdata(nil, "")
    end
  end
end
