# lib/moxml/error_handler.rb
module Moxml
  class ErrorHandler
    class << self
      def handle_parse_error(error, backend)
        case backend
        when :nokogiri
          handle_nokogiri_error(error)
        when :ox
          handle_ox_error(error)
        when :oga
          handle_oga_error(error)
        else
          handle_generic_error(error)
        end
      end

      private

      def handle_nokogiri_error(error)
        case error
        when ::Nokogiri::XML::SyntaxError
          raise ParseError.new(
            error.message,
            line: error.line,
            column: error.column,
            source: error.source,
          )
        when ::Nokogiri::XML::XPath::SyntaxError
          raise XPathError.new(error.message)
        else
          handle_generic_error(error)
        end
      end

      def handle_ox_error(error)
        case error
        when ::Ox::ParseError
          raise ParseError.new(
            error.message,
            line: error.line,
            column: error.column,
          )
        else
          handle_generic_error(error)
        end
      end

      def handle_oga_error(error)
        case error
        when ::Oga::XML::ParseError
          raise ParseError.new(
            error.message,
            line: error.line,
            column: error.column,
          )
        when ::Oga::XML::XPath::Error
          raise XPathError.new(error.message)
        else
          handle_generic_error(error)
        end
      end

      def handle_generic_error(error)
        case error
        when NameError, NoMethodError
          raise BackendError.new(
            "Backend operation failed: #{error.message}",
            Moxml.config.backend
          )
        else
          raise Error, "XML operation failed: #{error.message}"
        end
      end
    end
  end
end
