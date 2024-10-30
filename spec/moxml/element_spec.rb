# spec/moxml/element_spec.rb
RSpec.describe Moxml::Element do
  let(:element) { described_class.new("test") }

  describe "#new" do
    it "creates element with name" do
      expect(element.name).to eq("test")
    end

    it "wraps native element" do
      native = Moxml.adapter.create_element(nil, "test")
      element = described_class.new(native)
      expect(element.native).to eq(native)
    end
  end

  describe "#attributes" do
    before { element["id"] = "test-id" }

    it "returns hash of attributes" do
      expect(element.attributes).to be_a(Hash)
      expect(element.attributes["id"]).to be_a(Moxml::Attribute)
    end
  end

  describe "#[]" do
    before { element["class"] = "test-class" }

    it "gets attribute value" do
      expect(element["class"]).to be_a(Moxml::Attribute)
      expect(element["class"].value).to eq("test-class")
    end
  end

  describe "#[]=" do
    it "sets attribute value" do
      element["id"] = "new-id"
      expect(element["id"].value).to eq("new-id")
    end
  end

  describe "#add_child" do
    it "adds child node" do
      child = Moxml::Element.new("child")
      element.add_child(child)
      expect(element.children.first).to eq(child)
    end
  end

  describe "#classes" do
    before { element["class"] = "one two" }

    it "returns array of classes" do
      expect(element.classes).to eq(["one", "two"])
    end
  end

  describe "#add_class" do
    it "adds class" do
      element.add_class("test")
      expect(element.classes).to include("test")
    end

    it "prevents duplicate classes" do
      element.add_class("test")
      element.add_class("test")
      expect(element.classes.count("test")).to eq(1)
    end
  end

  describe "#remove_class" do
    before { element["class"] = "one two" }

    it "removes class" do
      element.remove_class("one")
      expect(element.classes).not_to include("one")
    end
  end

  describe "#has_class?" do
    before { element["class"] = "test" }

    it "checks class presence" do
      expect(element.has_class?("test")).to be true
      expect(element.has_class?("missing")).to be false
    end
  end
end
