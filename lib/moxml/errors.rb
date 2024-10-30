# lib/moxml/errors.rb
module Moxml
  # Base error class for all Moxml errors
  class Error < StandardError; end

  # Parsing related errors
  class ParseError < Error
    attr_reader :line, :column, :source

    def initialize(message, line: nil, column: nil, source: nil)
      @line = line
      @column = column
      @source = source
      super(build_message(message))
    end

    private

    def build_message(message)
      parts = [message]
      parts << "Line: #{line}" if line
      parts << "Column: #{column}" if column
      parts << "\nSource: #{source}" if source
      parts.join(" | ")
    end
  end

  # Validation errors
  class ValidationError < Error; end
  class DTDValidationError < ValidationError; end
  class SchemaValidationError < ValidationError; end
  class NamespaceError < ValidationError; end

  # Structure errors
  class MalformedXMLError < ParseError; end
  class UnbalancedTagError < ParseError; end
  class UndefinedEntityError < ParseError; end
  class DuplicateAttributeError < ParseError; end

  # Encoding errors
  class EncodingError < Error
    attr_reader :encoding

    def initialize(message, encoding)
      @encoding = encoding
      super("#{message} (Encoding: #{encoding})")
    end
  end

  # Security related errors
  class SecurityError < Error; end
  class MaxDepthExceededError < SecurityError; end
  class MaxAttributesExceededError < SecurityError; end
  class MaxNameLengthExceededError < SecurityError; end
  class EntityExpansionError < SecurityError; end

  # Backend errors
  class BackendError < Error
    attr_reader :backend

    def initialize(message, backend)
      @backend = backend
      super("#{message} (Backend: #{backend})")
    end
  end

  class BackendNotFoundError < BackendError; end
  class BackendConfigurationError < BackendError; end

  # Node manipulation errors
  class NodeError < Error
    attr_reader :node

    def initialize(message, node)
      @node = node
      super("#{message} (Node: #{node.class})")
    end
  end

  class InvalidNodeTypeError < NodeError; end
  class InvalidOperationError < NodeError; end
  class NodeNotFoundError < NodeError; end

  # Visitor pattern errors
  class VisitorError < Error; end

  class InvalidSelectorError < VisitorError
    attr_reader :selector

    def initialize(message, selector)
      @selector = selector
      super("#{message} (Selector: #{selector})")
    end
  end

  class VisitorMethodError < VisitorError
    attr_reader :method_name

    def initialize(message, method_name)
      @method_name = method_name
      super("#{message} (Method: #{method_name})")
    end
  end

  # Serialization errors
  class SerializationError < Error; end

  class InvalidOptionsError < SerializationError
    attr_reader :options

    def initialize(message, options)
      @options = options
      super("#{message} (Options: #{options})")
    end
  end

  # IO errors
  class IOError < Error
    attr_reader :path

    def initialize(message, path)
      @path = path
      super("#{message} (Path: #{path})")
    end
  end

  class FileNotFoundError < IOError; end
  class WriteError < IOError; end

  # Memory errors
  class MemoryError < Error
    attr_reader :size

    def initialize(message, size)
      @size = size
      super("#{message} (Size: #{size} bytes)")
    end
  end

  class DocumentTooLargeError < MemoryError; end

  # CDATA related errors
  class CDATAError < Error; end
  class NestedCDATAError < CDATAError; end
  class InvalidCDATAContentError < CDATAError; end

  # Namespace related errors
  class NamespaceDeclarationError < Error
    attr_reader :prefix, :uri

    def initialize(message, prefix, uri)
      @prefix = prefix
      @uri = uri
      super("#{message} (Prefix: #{prefix}, URI: #{uri})")
    end
  end

  # XPath related errors
  class XPathError < Error
    attr_reader :expression

    def initialize(message, expression)
      @expression = expression
      super("#{message} (Expression: #{expression})")
    end
  end

  class InvalidXPathError < XPathError; end
end
