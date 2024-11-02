RSpec.describe "Adapter Examples" do
  let(:xml) { "<root><child>text</child></root>" }

  describe "Adapter switching" do
    it "works with Nokogiri adapter" do
      context = Moxml.new(:nokogiri)
      doc = context.parse(xml)
      expect(doc.root.children.first.text).to eq("text")
    end

    it "works with Ox adapter" do
      context = Moxml.new(:ox)
      doc = context.parse(xml)
      expect(doc.root.children.first.text).to eq("text")
    end

    it "works with Oga adapter" do
      context = Moxml.new(:oga)
      doc = context.parse(xml)
      expect(doc.root.children.first.text).to eq("text")
    end

    it "produces identical output with different adapters" do
      nokogiri_out = Moxml.new(:nokogiri).parse(xml).to_xml
      ox_out = Moxml.new(:ox).parse(xml).to_xml
      oga_out = Moxml.new(:oga).parse(xml).to_xml

      expect(normalize_xml(nokogiri_out)).to eq(normalize_xml(ox_out))
      expect(normalize_xml(nokogiri_out)).to eq(normalize_xml(oga_out))
    end
  end

  private

  def normalize_xml(xml)
    xml.gsub(/>\s+</, "><").strip
  end
end
