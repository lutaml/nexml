# spec/moxml/cdata_spec.rb
RSpec.describe Moxml::Cdata do
  let(:cdata) { described_class.new("<content>") }

  describe "#new" do
    it "creates CDATA section with content" do
      expect(cdata.content).to eq("<content>")
    end
  end

  describe "#to_xml" do
    it "serializes to CDATA section" do
      expect(cdata.to_xml).to eq("<![CDATA[<content>]]>")
    end
  end

  describe "#cdata?" do
    it "returns true" do
      expect(cdata.cdata?).to be true
    end
  end
end
