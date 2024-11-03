require "oga"
require "moxml/adapter/oga"

RSpec.describe Moxml::Adapter::Oga do
  before(:all) do
    Moxml.configure do |config|
      config.adapter = :oga
      config.strict_parsing = true
      config.default_encoding = "UTF-8"
    end
  end

  it_behaves_like "xml adapter"
end
