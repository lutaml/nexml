# spec/moxml/namespace_spec.rb
RSpec.describe Moxml::Namespace do
  let(:namespace) { described_class.new("prefix", "http://example.com") }

  describe "#new" do
    it "creates namespace with prefix and URI" do
      expect(namespace.prefix).to eq("prefix")
      expect(namespace.uri).to eq("http://example.com")
    end
  end

  describe "#==" do
    it "compares namespaces" do
      other = described_class.new("prefix", "http://example.com")
      expect(namespace).to eq(other)
    end
  end

  describe "#to_s" do
    it "formats namespace declaration" do
      expect(namespace.to_s).to eq("xmlns:prefix='http://example.com'")
    end

    it "formats default namespace declaration" do
      namespace = described_class.new(nil, "http://example.com")
      expect(namespace.to_s).to eq("xmlns='http://example.com'")
    end
  end
end
