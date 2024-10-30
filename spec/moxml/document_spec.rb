# spec/moxml/document_spec.rb
RSpec.describe Moxml::Document do
  let(:xml_string) { "<root><child>text</child></root>" }

  describe ".parse" do
    it "parses XML string" do
      doc = described_class.parse(xml_string)
      expect(doc).to be_a(Moxml::Document)
      expect(doc.root.name).to eq("root")
    end

    it "parses XML with encoding" do
      doc = described_class.parse(xml_string, encoding: "UTF-8")
      expect(doc.encoding).to eq("UTF-8")
    end

    it "raises ParseError for invalid XML" do
      expect {
        described_class.parse("<invalid>")
      }.to raise_error(Moxml::ParseError)
    end
  end

  describe "#new" do
    it "creates empty document" do
      doc = described_class.new
      expect(doc).to be_a(Moxml::Document)
      expect(doc.root).to be_nil
    end

    it "wraps native document" do
      native_doc = Moxml.adapter.parse(xml_string)
      doc = described_class.new(native_doc)
      expect(doc.native).to eq(native_doc)
    end
  end

  describe "#create_element" do
    let(:doc) { described_class.new }

    it "creates new element" do
      element = doc.create_element("test")
      expect(element).to be_a(Moxml::Element)
      expect(element.name).to eq("test")
    end
  end

  describe "#create_text" do
    let(:doc) { described_class.new }

    it "creates text node" do
      text = doc.create_text("content")
      expect(text).to be_a(Moxml::Text)
      expect(text.content).to eq("content")
    end
  end

  describe "#create_cdata" do
    let(:doc) { described_class.new }

    it "creates CDATA section" do
      cdata = doc.create_cdata("<text>")
      expect(cdata).to be_a(Moxml::Cdata)
      expect(cdata.content).to eq("<text>")
    end
  end

  describe "#create_comment" do
    let(:doc) { described_class.new }

    it "creates comment" do
      comment = doc.create_comment("test comment")
      expect(comment).to be_a(Moxml::Comment)
      expect(comment.content).to eq("test comment")
    end
  end

  describe "#create_processing_instruction" do
    let(:doc) { described_class.new }

    it "creates processing instruction" do
      pi = doc.create_processing_instruction("xml-stylesheet", 'href="style.css"')
      expect(pi).to be_a(Moxml::ProcessingInstruction)
      expect(pi.target).to eq("xml-stylesheet")
      expect(pi.content).to eq('href="style.css"')
    end
  end

  describe "#to_xml" do
    let(:doc) { described_class.parse(xml_string) }

    it "serializes to XML string" do
      expect(doc.to_xml).to be_equivalent_to(xml_string)
    end

    it "respects serialization options" do
      expect(doc.to_xml(indent: 2)).to include("\n")
    end
  end

  describe "document properties" do
    let(:doc) { described_class.new }

    it "manages encoding" do
      doc.encoding = "UTF-8"
      expect(doc.encoding).to eq("UTF-8")
    end

    it "manages version" do
      doc.version = "1.1"
      expect(doc.version).to eq("1.1")
    end

    it "manages standalone" do
      doc.standalone = "yes"
      expect(doc.standalone).to eq("yes")
    end
  end
end
