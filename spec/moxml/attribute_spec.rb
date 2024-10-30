# spec/moxml/attribute_spec.rb
RSpec.describe Moxml::Attribute do
  let(:attribute) { described_class.new("name", "value") }

  describe "#new" do
    it "creates attribute with name and value" do
      expect(attribute.name).to eq("name")
      expect(attribute.value).to eq("value")
    end
  end

  describe "#value=" do
    it "updates attribute value" do
      attribute.value = "new-value"
      expect(attribute.value).to eq("new-value")
    end
  end

  describe "#namespace" do
    let(:element) { Moxml::Element.new("test") }
    let(:attribute) { element["test"] }

    before do
      element.add_namespace("ns", "http://example.com")
    end

    it "returns namespace" do
      expect(attribute.namespace).to be_nil
      # Add namespace-specific tests based on your implementation
    end
  end
end
