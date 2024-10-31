# lib/moxml/context.rb
module Moxml
  class Context
    attr_reader :config

    def initialize(adapter = Config::DEFAULT_ADAPTER)
      @config = Config.new(adapter)
    end

    def parse(xml, options = {})
      Document.new(config.adapter.parse(xml, default_options.merge(options)), self)
    end

    def create_document
      Document.new(config.adapter.create_document, self)
    end

    private

    def default_options
      {
        encoding: config.default_encoding,
        strict: config.strict_parsing,
        indent: config.default_indent,
      }
    end
  end
end
