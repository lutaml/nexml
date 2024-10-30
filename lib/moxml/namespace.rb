module Moxml
  class Namespace < Node
    def initialize(prefix_or_native = nil, uri = nil)
      case prefix_or_native
      when String
        super(adapter.create_namespace(nil, prefix_or_native, uri))
      else
        super(prefix_or_native)
      end
    end

    def prefix
      adapter.namespace_prefix(native)
    end

    def prefix=(new_prefix)
      adapter.set_namespace_prefix(native, new_prefix)
      self
    end

    def uri
      adapter.namespace_uri(native)
    end

    def uri=(new_uri)
      adapter.set_namespace_uri(native, new_uri)
      self
    end

    def blank?
      uri.nil? || uri.empty?
    end

    def namespace?
      true
    end

    def ==(other)
      other.is_a?(Namespace) &&
        other.prefix == prefix &&
        other.uri == uri
    end

    def to_s
      prefix ? "xmlns:#{prefix}='#{uri}'" : "xmlns='#{uri}'"
    end

    private

    def create_native_node
      adapter.create_namespace(nil, "", "")
    end
  end
end
