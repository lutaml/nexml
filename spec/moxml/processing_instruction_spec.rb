# spec/moxml/processing_instruction_spec.rb
RSpec.describe Moxml::ProcessingInstruction do
  let(:pi) { described_class.new("xml-stylesheet", 'href="style.css"') }

  describe "#new" do
    it "creates processing instruction with target and content" do
      expect(pi.target).to eq("xml-stylesheet")
      expect(pi.content).to eq('href="style.css"')
    end
  end

  describe "#to_xml" do
    it "serializes to processing instruction" do
      expect(pi.to_xml).to eq('<?xml-stylesheet href="style.css"?>')
    end
  end
end
