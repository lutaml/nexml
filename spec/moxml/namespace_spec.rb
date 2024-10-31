# spec/moxml/namespace_spec.rb
RSpec.describe Moxml::Namespace do
  let(:context) { Moxml.new }
  let(:doc) { context.create_document }
  let(:element) { doc.create_element("test") }

  describe "creation" do
    it "creates namespace with prefix" do
      element.add_namespace("xs", "http://www.w3.org/2001/XMLSchema")
      ns = element.namespaces.first

      expect(ns).to be_namespace
      expect(ns.prefix).to eq("xs")
      expect(ns.uri).to eq("http://www.w3.org/2001/XMLSchema")
    end

    it "creates default namespace" do
      element.add_namespace(nil, "http://example.org")
      ns = element.namespaces.first

      expect(ns.prefix).to be_nil
      expect(ns.uri).to eq("http://example.org")
    end

    it "validates URI" do
      expect {
        element.add_namespace("xs", "invalid uri")
      }.to raise_error(Moxml::NamespaceError)
    end
  end

  describe "string representation" do
    it "formats prefixed namespace" do
      element.add_namespace("xs", "http://www.w3.org/2001/XMLSchema")
      expect(element.namespaces.first.to_s).to eq('xmlns:xs="http://www.w3.org/2001/XMLSchema"')
    end

    it "formats default namespace" do
      element.add_namespace(nil, "http://example.org")
      expect(element.namespaces.first.to_s).to eq('xmlns="http://example.org"')
    end
  end

  describe "equality" do
    let(:ns1) { element.add_namespace("xs", "http://www.w3.org/2001/XMLSchema").namespaces.first }
    let(:ns2) { element.add_namespace("xs", "http://www.w3.org/2001/XMLSchema").namespaces.first }
    let(:ns3) { element.add_namespace("xsi", "http://www.w3.org/2001/XMLSchema-instance").namespaces.first }

    it "compares namespaces" do
      expect(ns1).to eq(ns2)
      expect(ns1).not_to eq(ns3)
    end

    it "compares with different elements" do
      other_element = doc.create_element("other")
      other_ns = other_element.add_namespace("xs", "http://www.w3.org/2001/XMLSchema").namespaces.first
      expect(ns1).to eq(other_ns)
    end
  end

  describe "inheritance" do
    it "inherits parent namespaces" do
      root = doc.create_element("root")
      root.add_namespace("xs", "http://www.w3.org/2001/XMLSchema")
      child = doc.create_element("child")
      root.add_child(child)

      expect(child.namespace.prefix).to eq("xs")
      expect(child.namespace.uri).to eq("http://www.w3.org/2001/XMLSchema")
    end

    it "overrides parent namespace" do
      root = doc.create_element("root")
      root.add_namespace("ns", "http://example.org/1")
      child = doc.create_element("child")
      child.add_namespace("ns", "http://example.org/2")
      root.add_child(child)

      expect(root.namespace.uri).to eq("http://example.org/1")
      expect(child.namespace.uri).to eq("http://example.org/2")
    end
  end
end
