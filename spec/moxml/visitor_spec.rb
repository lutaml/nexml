RSpec.describe Moxml::DocumentBuilder do
  let(:context) { Moxml.new }
  let(:builder) { described_class.new(context) }

  describe "#build" do
    it "builds a document model from native document" do
      xml = "<root><child>text</child></root>"
      native_doc = context.config.adapter.parse(xml)
      doc = builder.build(native_doc)

      expect(doc).to be_a(Moxml::Document)
      expect(doc.root).to be_a(Moxml::Element)
      expect(doc.root.name).to eq("root")
      expect(doc.root.children.first).to be_a(Moxml::Element)
      expect(doc.root.children.first.text).to eq("text")
    end

    it "handles complex documents" do
      xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <root xmlns="http://example.org">
          <!-- comment -->
          <child id="1">
            <![CDATA[cdata content]]>
          </child>
          <?pi target data?>
        </root>
      XML

      native_doc = context.config.adapter.parse(xml)
      doc = builder.build(native_doc)

      expect(doc.root.namespaces.first.uri).to eq("http://example.org")
      expect(doc.root.children[0]).to be_a(Moxml::Comment)
      expect(doc.root.children[1]).to be_a(Moxml::Element)
      expect(doc.root.children[1]["id"]).to eq("1")
      expect(doc.root.children[1].children.first).to be_a(Moxml::Cdata)
      expect(doc.root.children[2]).to be_a(Moxml::ProcessingInstruction)
    end
  end
end
