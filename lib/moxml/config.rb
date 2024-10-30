# lib/moxml/config.rb
module Moxml
  class Config
    attr_accessor :backend, :huge_document,
                  :default_encoding,
                  :default_indent,
                  :cdata_sections,
                  :cdata_patterns,
                  :strict_parsing,
                  :entity_encoding

    def initialize
      @backend = :nokogiri
      @huge_document = false
      @default_encoding = "UTF-8"
      @default_indent = 2
      @cdata_sections = true
      @cdata_patterns = ["script", "style"]
      @strict_parsing = true
      @entity_encoding = :basic
    end
  end
end
