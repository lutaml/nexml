# spec/moxml/text_spec.rb
RSpec.describe Moxml::Text do
  let(:text) { described_class.new("content") }

  describe "#new" do
    it "creates text node with content" do
      expect(text.content).to eq("content")
    end
  end

  describe "#content=" do
    it "updates text content" do
      text.content = "new content"
      expect(text.content).to eq("new content")
    end
  end

  describe "#blank?" do
    it "checks if content is blank" do
      expect(described_class.new("  ").blank?).to be true
      expect(described_class.new("content").blank?).to be false
    end
  end
end
