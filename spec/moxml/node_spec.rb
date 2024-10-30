# spec/moxml/node_spec.rb
RSpec.describe Moxml::Node do
  let(:xml_string) { "<root><child>text</child></root>" }
  let(:doc) { Moxml::Document.parse(xml_string) }
  let(:node) { doc.root }

  describe ".wrap" do
    it "wraps native node in appropriate class" do
      expect(described_class.wrap(doc.native)).to be_a(Moxml::Document)
      expect(described_class.wrap(node.native)).to be_a(Moxml::Element)
    end

    it "returns nil for nil input" do
      expect(described_class.wrap(nil)).to be_nil
    end
  end

  describe "#parent" do
    it "returns parent node" do
      child = node.children.first
      expect(child.parent).to eq(node)
    end
  end

  describe "#children" do
    it "returns node children" do
      expect(node.children).to be_a(Moxml::NodeSet)
      expect(node.children.size).to eq(1)
    end
  end

  describe "#next_sibling" do
    let(:xml_string) { "<root><first/><second/></root>" }

    it "returns next sibling" do
      first = doc.root.children.first
      expect(first.next_sibling.name).to eq("second")
    end
  end

  describe "#previous_sibling" do
    let(:xml_string) { "<root><first/><second/></root>" }

    it "returns previous sibling" do
      second = doc.root.children.last
      expect(second.previous_sibling.name).to eq("first")
    end
  end
end
