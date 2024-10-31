# lib/moxml/declaration.rb
module Moxml
  class Declaration < Node
    def version
      adapter.declaration_version(@native)
    end

    def version=(new_version)
      adapter.set_declaration_version(@native, new_version)
      self
    end

    def encoding
      adapter.declaration_encoding(@native)
    end

    def encoding=(new_encoding)
      adapter.set_declaration_encoding(@native, new_encoding)
      self
    end

    def standalone
      adapter.declaration_standalone(@native)
    end

    def standalone=(new_standalone)
      adapter.set_declaration_standalone(@native, new_standalone)
      self
    end

    def declaration?
      true
    end
  end
end
