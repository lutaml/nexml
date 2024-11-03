# lib/moxml/declaration.rb
module Moxml
  class Declaration < Node
    def version
      extract_attribute("version")
    end

    def version=(new_version)
      update_content("version", new_version)
    end

    def encoding
      extract_attribute("encoding")
    end

    def encoding=(new_encoding)
      update_content("encoding", new_encoding)
    end

    def standalone
      extract_attribute("standalone")
    end

    def standalone=(new_standalone)
      update_content("standalone", new_standalone)
    end

    def declaration?
      true
    end

    private

    def extract_attribute(name)
      return nil unless @native.content
      match = @native.content.match(/#{name}="([^"]*)"/)
      match && match[1]
    end

    def update_content(name, value)
      content = @native.content || ""
      if value.nil?
        content.gsub!(/\s*#{name}="[^"]*"/, "")
      else
        if content.include?("#{name}=\"")
          content.gsub!(/#{name}="[^"]*"/, "#{name}=\"#{value}\"")
        else
          content << " #{name}=\"#{value}\""
        end
      end
      @native.content = content.strip
      self
    end
  end
end
