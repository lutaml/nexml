module Moxml
  class Cdata < Node
    def content
      adapter.cdata_content(@native)
    end

    def content=(text)
      adapter.set_cdata_content(@native, normalize_xml_value(text))
      self
    end

    def cdata?
      true
    end
  end
end
