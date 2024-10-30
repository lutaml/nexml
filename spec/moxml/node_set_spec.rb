# spec/moxml/node_set_spec.rb
RSpec.describe Moxml::NodeSet do
  let(:xml) { '<root><child class="one">first</child><child class="two">second</child></root>' }
  let(:doc) { Moxml::Document.parse(xml) }
  let(:node_set) { doc.root.children }

  describe "#each" do
    it "iterates over nodes" do
      expect(node_set.map(&:text)).to eq(["first", "second"])
    end
  end

  describe "#[]" do
    it "accesses node by index" do
      expect(node_set[0].text).to eq("first")
    end

    it "returns node set for range" do
      expect(node_set[0..1]).to be_a(described_class)
      expect(node_set[0..1].size).to eq(2)
    end
  end

  describe "#filter" do
    it "filters nodes by selector" do
      filtered = node_set.filter(".one")
      expect(filtered.size).to eq(1)
      expect(filtered.first["class"].value).to eq("one")
    end
  end

  describe "set operations" do
    let(:other_set) { doc.css(".two") }

    it "supports union" do
      result = node_set | other_set
      expect(result.size).to eq(2)
    end

    it "supports intersection" do
      result = node_set & other_set
      expect(result.size).to eq(1)
    end

    it "supports difference" do
      result = node_set - other_set
      expect(result.size).to eq(1)
    end
  end

  describe "#wrap" do
    it "wraps nodes in element" do
      node_set.wrap('<div class="wrapper"></div>')
      expect(doc.css(".wrapper").size).to eq(2)
    end
  end

  describe "attribute operations" do
    it "adds class to nodes" do
      node_set.add_class("new")
      expect(node_set.all? { |n| n.has_class?("new") }).to be true
    end

    it "removes class from nodes" do
      node_set.remove_class("one")
      expect(node_set.none? { |n| n.has_class?("one") }).to be true
    end
  end
end
