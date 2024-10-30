# lib/moxml.rb
require_relative "moxml/version"
require_relative "moxml/config"
require_relative "moxml/document"
require_relative "moxml/node"
require_relative "moxml/element"
require_relative "moxml/text"
require_relative "moxml/cdata_section"
require_relative "moxml/comment"
require_relative "moxml/processing_instruction"
require_relative "moxml/visitor"
require_relative "moxml/errors"
require_relative "moxml/backends/base"

module Moxml
  class << self
    def config
      @config ||= Config.new
    end

    def configure
      yield(config)
    end

    def backend
      @backend ||= begin
          backend_class = case config.backend
            when :nokogiri
              require_relative "moxml/backends/nokogiri"
              Backends::Nokogiri
            when :ox
              require_relative "moxml/backends/ox"
              Backends::Ox
            when :oga
              require_relative "moxml/backends/oga"
              Backends::Oga
            else
              raise ArgumentError, "Unknown backend: #{config.backend}"
            end
          backend_class.new
        end
    end
  end
end
