# spec/moxml/adapter/nokogiri_spec.rb
require "nokogiri"

RSpec.describe Moxml::Adapter::Nokogiri do
  it_behaves_like "xml adapter"
end
