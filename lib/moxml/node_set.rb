# lib/moxml/node_set.rb
module Moxml
  class NodeSet
    include Enumerable

    attr_reader :native_nodes

    def initialize(native_nodes = [])
      @native_nodes = Array(native_nodes)
    end

    def each
      return enum_for(:each) unless block_given?
      native_nodes.each { |node| yield Node.wrap(node) }
      self
    end

    def [](index)
      case index
      when Integer
        Node.wrap(native_nodes[index])
      when Range
        NodeSet.new(native_nodes[index])
      end
    end

    def first
      Node.wrap(native_nodes.first)
    end

    def last
      Node.wrap(native_nodes.last)
    end

    def empty?
      native_nodes.empty?
    end

    def size
      native_nodes.size
    end

    alias length size

    def to_a
      map { |node| node }
    end

    def filter(selector)
      NodeSet.new(
        native_nodes.select { |node| Moxml.adapter.matches?(node, selector) }
      )
    end

    def remove
      each(&:remove)
      self
    end

    def text
      map(&:text).join
    end

    def inner_html
      map(&:inner_html).join
    end

    def wrap(html_or_element)
      each do |node|
        wrapper = case html_or_element
          when String
            Document.parse("<div>#{html_or_element}</div>").root.children.first
          when Element
            html_or_element.dup
          else
            raise ArgumentError, "Expected String or Element"
          end

        node.add_previous_sibling(wrapper)
        wrapper.add_child(node)
      end
      self
    end

    def add_class(names)
      each do |node|
        next unless node.is_a?(Element)
        current = (node["class"] || "").split(/\s+/)
        new_classes = names.is_a?(Array) ? names : names.split(/\s+/)
        node["class"] = (current + new_classes).uniq.join(" ")
      end
      self
    end

    def remove_class(names)
      each do |node|
        next unless node.is_a?(Element)
        current = (node["class"] || "").split(/\s+/)
        remove_classes = names.is_a?(Array) ? names : names.split(/\s+/)
        node["class"] = (current - remove_classes).join(" ")
      end
      self
    end

    def attr(name, value = nil)
      if value.nil?
        first&.[](name)
      else
        each { |node| node[name] = value if node.is_a?(Element) }
        self
      end
    end

    # Collection operations
    def +(other)
      NodeSet.new(native_nodes + other.native_nodes)
    end

    def -(other)
      NodeSet.new(native_nodes - other.native_nodes)
    end

    def &(other)
      NodeSet.new(native_nodes & other.native_nodes)
    end

    def |(other)
      NodeSet.new(native_nodes | other.native_nodes)
    end

    def uniq
      NodeSet.new(native_nodes.uniq)
    end

    def reverse
      NodeSet.new(native_nodes.reverse)
    end

    # Search and filtering
    def find_by_id(id)
      detect { |node| node.is_a?(Element) && node["id"] == id }
    end

    def find_by_class(class_name)
      select { |node| node.is_a?(Element) && (node["class"] || "").split(/\s+/).include?(class_name) }
    end

    def find_by_attribute(name, value = nil)
      select do |node|
        next unless node.is_a?(Element)
        if value.nil?
          node.attributes.key?(name)
        else
          node[name] == value
        end
      end
    end

    def of_type(type)
      select { |node| node.is_a?(type) }
    end

    # DOM Manipulation
    def before(node_or_nodes)
      each { |node| node.add_previous_sibling(node_or_nodes) }
      self
    end

    def after(node_or_nodes)
      each { |node| node.add_next_sibling(node_or_nodes) }
      self
    end

    def replace_with(node_or_nodes)
      each { |node| node.replace(node_or_nodes) }
      self
    end

    def wrap_all(wrapper)
      return self if empty?

      wrapper_node = case wrapper
        when String
          Document.parse(wrapper).root
        when Element
          wrapper
        else
          raise ArgumentError, "Expected String or Element"
        end

      first.add_previous_sibling(wrapper_node)
      wrapper_node.add_child(self)
      self
    end

    # Content manipulation
    def inner_text=(text)
      each { |node| node.inner_text = text }
      self
    end

    def inner_html=(html)
      each { |node| node.inner_html = html }
      self
    end

    # Attribute operations
    def toggle_class(names)
      names = names.split(/\s+/) if names.is_a?(String)
      each do |node|
        next unless node.is_a?(Element)
        current = (node["class"] || "").split(/\s+/)
        names.each do |name|
          if current.include?(name)
            current.delete(name)
          else
            current << name
          end
        end
        node["class"] = current.uniq.join(" ")
      end
      self
    end

    def has_class?(name)
      any? { |node| node.is_a?(Element) && (node["class"] || "").split(/\s+/).include?(name) }
    end

    def remove_attr(*attrs)
      each do |node|
        next unless node.is_a?(Element)
        attrs.each { |attr| node.remove_attribute(attr) }
      end
      self
    end

    # Position and hierarchy
    def parents
      NodeSet.new(
        map { |node| node.parent }.compact.uniq
      )
    end

    def children
      NodeSet.new(
        flat_map { |node| node.children.to_a }
      )
    end

    def siblings
      NodeSet.new(
        flat_map { |node| node.parent ? node.parent.children.reject { |sibling| sibling == node } : [] }
      ).uniq
    end

    def next
      NodeSet.new(
        map { |node| node.next_sibling }.compact
      )
    end

    def previous
      NodeSet.new(
        map { |node| node.previous_sibling }.compact
      )
    end
  end
end
