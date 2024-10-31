# lib/moxml.rb
module Moxml
  def self.new(adapter = :nokogiri)
    Context.new(adapter)
  end
end

require_relative "moxml/version"
require_relative "moxml/error"
require_relative "moxml/config"
require_relative "moxml/context"
require_relative "moxml/adapter/base"
require_relative "moxml/adapter/nokogiri"
require_relative "moxml/adapter/oga"
require_relative "moxml/adapter/ox"
require_relative "moxml/node"
require_relative "moxml/attribute"
require_relative "moxml/document"
require_relative "moxml/element"
require_relative "moxml/text"
require_relative "moxml/comment"
require_relative "moxml/cdata"
require_relative "moxml/processing_instruction"
require_relative "moxml/declaration"
require_relative "moxml/namespace"
require_relative "moxml/node_set"
