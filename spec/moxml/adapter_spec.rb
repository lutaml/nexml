# spec/moxml/adapter_spec.rb
RSpec.describe Moxml::Adapter do
  # These specs should be run for each adapter implementation
  shared_examples "xml adapter" do
    let(:adapter) { described_class.new }
    let(:xml) { '<root><child id="1">text</child></root>' }

    describe "#parse" do
      it "parses XML string" do
        doc = adapter.parse(xml)
        expect(adapter.node_type(doc)).to eq(:document)
      end

      it "raises error for invalid XML" do
        expect { adapter.parse("<invalid>") }.to raise_error(Moxml::ParseError)
      end
    end

    describe "#serialize" do
      let(:doc) { adapter.parse(xml) }

      it "serializes to XML string" do
        result = adapter.serialize(doc)
        expect(result).to be_equivalent_to(xml)
      end
    end

    describe "node operations" do
      let(:doc) { adapter.parse(xml) }
      let(:root) { adapter.root(doc) }

      it "accesses node name" do
        expect(adapter.node_name(root)).to eq("root")
      end

      it "accesses node attributes" do
        child = adapter.children(root).first
        expect(adapter.get_attribute(child, "id")).not_to be_nil
      end

      it "modifies node attributes" do
        child = adapter.children(root).first
        adapter.set_attribute(child, "class", "new")
        expect(adapter.get_attribute(child, "class")).not_to be_nil
      end
    end
  end

  describe Moxml::NokogiriAdapter do
    it_behaves_like "xml adapter"
  end

  describe Moxml::OxAdapter do
    it_behaves_like "xml adapter"
  end

  describe Moxml::OgaAdapter do
    it_behaves_like "xml adapter"
  end
end
