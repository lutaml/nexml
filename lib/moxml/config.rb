# lib/moxml/config.rb
module Moxml
  class Config
    VALID_ADAPTERS = [:nokogiri, :oga, :ox].freeze
    DEFAULT_ADAPTER = :nokogiri

    class << self
      def default
        @default ||= new
      end
    end

    attr_reader :adapter_name
    attr_accessor :strict_parsing,
                  :default_encoding,
                  :default_indent

    def initialize(adapter_name = DEFAULT_ADAPTER)
      self.adapter = adapter_name
      @strict_parsing = true
      @default_encoding = "UTF-8"
      @default_indent = 2
    end

    def adapter=(name)
      name = name.to_sym
      unless VALID_ADAPTERS.include?(name)
        @adapter = nil
        raise ArgumentError, "Invalid adapter: #{name}. Valid adapters are: #{VALID_ADAPTERS.join(", ")}"
      end

      @adapter_name = name
      adapter
    end

    alias default_adapter= adapter=

    def adapter
      @adapter ||= Adapter.load(@adapter_name)
    end
  end
end
