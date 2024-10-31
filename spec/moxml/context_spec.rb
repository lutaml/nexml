# spec/moxml/context_spec.rb
RSpec.describe Moxml::Context do
  subject(:context) { described_class.new }

  describe "#initialize" do
    it "creates config with default adapter" do
      expect(context.config).to be_a(Moxml::Config)
      expect(context.config.adapter_name).to eq(:nokogiri)
    end

    it "accepts specific adapter" do
      context = described_class.new(:ox)
      expect(context.config.adapter_name).to eq(:ox)
    end
  end

  describe "#parse" do
    let(:xml) { "<root><child>text</child></root>" }

    it "parses XML string" do
      doc = context.parse(xml)
      expect(doc).to be_a(Moxml::Document)
      expect(doc.root.name).to eq("root")
    end

    it "respects configuration options" do
      context.config.strict_parsing = false
      expect { context.parse("<invalid>") }.not_to raise_error
    end

    it "raises ParseError for invalid XML when strict" do
      context.config.strict_parsing = true
      expect { context.parse("<invalid>") }.to raise_error(Moxml::ParseError)
    end
  end

  describe "#create_document" do
    it "creates empty document" do
      doc = context.create_document
      expect(doc).to be_a(Moxml::Document)
      expect(doc.root).to be_nil
    end
  end
end
