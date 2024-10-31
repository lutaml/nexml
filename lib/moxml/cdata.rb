# lib/moxml/cdata.rb
module Moxml
  class Cdata < Node
    def content
      adapter.cdata_content(@native)
    end

    def content=(text)
      adapter.set_cdata_content(@native, text)
      self
    end

    def cdata?
      true
    end
  end
end
