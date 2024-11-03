RSpec.describe Moxml::Context do
  describe "#parse" do
    it "returns a Moxml::Document" do
      doc = subject.parse("<root/>")
      expect(doc).to be_a(Moxml::Document)
    end

    it "builds complete document model" do
      doc = subject.parse("<root><child>text</child></root>")
      expect(doc.root).to be_a(Moxml::Element)
      expect(doc.root.children.first).to be_a(Moxml::Element)
      expect(doc.root.children.first.children.first).to be_a(Moxml::Text)
    end

    it "maintains document structure" do
      doc = subject.parse(<<~XML)
        <?xml version="1.0"?>
        <!-- comment -->
        <root>
          <![CDATA[data]]>
          <?pi target?>
        </root>
      XML

      expect(doc.children[1]).to be_a(Moxml::Comment)
      expect(doc.root.children[0]).to be_a(Moxml::Cdata)
      expect(doc.root.children[1]).to be_a(Moxml::ProcessingInstruction)
    end
  end
end
