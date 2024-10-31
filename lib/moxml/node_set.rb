# lib/moxml/node_set.rb
module Moxml
  class NodeSet
    include Enumerable

    attr_reader :nodes, :context

    def initialize(nodes, context)
      @nodes = Array(nodes)
      @context = context
    end

    def each
      return to_enum(:each) unless block_given?
      nodes.each { |node| yield Node.wrap(node, context) }
      self
    end

    def [](index)
      case index
      when Integer
        Node.wrap(nodes[index], context)
      when Range
        NodeSet.new(nodes[index], context)
      end
    end

    def first
      Node.wrap(nodes.first, context)
    end

    def last
      Node.wrap(nodes.last, context)
    end

    def empty?
      nodes.empty?
    end

    def size
      nodes.size
    end

    alias length size

    def to_a
      map { |node| node }
    end

    def map
      return to_enum(:map) unless block_given?
      nodes.map { |node| yield Node.wrap(node, context) }
    end

    def select
      return to_enum(:select) unless block_given?
      NodeSet.new(
        nodes.select { |node| yield Node.wrap(node, context) },
        context
      )
    end

    def remove
      each(&:remove)
      self
    end

    def text
      map(&:text).join
    end
  end
end
