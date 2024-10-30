# lib/moxml/declaration.rb
module Moxml
  class Declaration < Node
    def initialize(version_or_native = "1.0", encoding = "UTF-8", standalone = nil)
      case version_or_native
      when String
        super(adapter.create_declaration(nil, version_or_native, encoding, standalone))
      else
        super(version_or_native)
      end
    end

    def version
      adapter.declaration_version(native)
    end

    def version=(new_version)
      adapter.set_declaration_version(native, new_version)
      self
    end

    def encoding
      adapter.declaration_encoding(native)
    end

    def encoding=(new_encoding)
      adapter.set_declaration_encoding(native, new_encoding)
      self
    end

    def standalone
      adapter.declaration_standalone(native)
    end

    def standalone=(new_standalone)
      adapter.set_declaration_standalone(native, new_standalone)
      self
    end

    def to_xml
      adapter.serialize_declaration(native)
    end

    private

    def create_native_node
      adapter.create_declaration(nil, "1.0", "UTF-8", nil)
    end
  end
end
