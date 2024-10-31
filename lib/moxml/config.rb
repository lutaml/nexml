# lib/moxml/config.rb
module Moxml
  class Config
    VALID_ADAPTERS = [:nokogiri, :oga, :ox].freeze
    DEFAULT_ADAPTER = :nokogiri

    attr_reader :adapter_name
    attr_accessor :strict_parsing,
                  :default_encoding,
                  :default_indent,
                  :entity_encoding

    def initialize(adapter_name = DEFAULT_ADAPTER)
      self.adapter = adapter_name
      @strict_parsing = true
      @default_encoding = "UTF-8"
      @default_indent = 2
      @entity_encoding = :basic
    end

    def adapter=(name)
      name = name.to_sym
      unless VALID_ADAPTERS.include?(name)
        raise ArgumentError, "Invalid adapter: #{name}. Valid adapters are: #{VALID_ADAPTERS.join(", ")}"
      end

      require_adapter(name)
      @adapter_name = name
      @adapter = nil
    end

    def adapter
      @adapter ||= case @adapter_name
        when :nokogiri then Adapter::Nokogiri
        when :oga then Adapter::Oga
        when :ox then Adapter::Ox
        else
          raise "Unknown adapter: #{@adapter_name}"
        end
    end

    private

    def require_adapter(name)
      case name
      when :nokogiri
        require "nokogiri"
        require "moxml/adapter/nokogiri"
      when :oga
        require "oga"
        require "moxml/adapter/oga"
      when :ox
        require "ox"
        require "moxml/adapter/ox"
      end
    rescue LoadError => e
      raise LoadError, "Could not load #{name} adapter. Please ensure the #{name} gem is available: #{e.message}"
    end
  end
end
