require "nokogiri"
require "moxml/adapter/nokogiri"

RSpec.describe Moxml::Adapter::Nokogiri do
  before(:all) do
    Moxml.configure do |config|
      config.adapter = :nokogiri
      config.strict_parsing = true
      config.default_encoding = "UTF-8"
    end
  end

  it_behaves_like "xml adapter"
end
