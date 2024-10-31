# spec/moxml/edge_cases_spec.rb
RSpec.describe "Moxml Edge Cases" do
  let(:context) { Moxml.new }

  describe "special characters handling" do
    it "handles all kinds of whitespace" do
      xml = "<root>\u0020\u0009\u000D\u000A</root>"
      doc = context.parse(xml)
      expect(doc.root.text).to eq(" \t\r\n")
    end

    it "handles unicode characters" do
      text = "Hello 世界 🌍"
      doc = context.create_document
      element = doc.create_element("test")
      element.text = text
      expect(element.text).to eq(text)
    end

    it "handles zero-width characters" do
      text = "test\u200B\u200Ctest"
      doc = context.create_document
      element = doc.create_element("test")
      element.text = text
      expect(element.text).to eq(text)
    end
  end

  describe "malformed content handling" do
    it "handles CDATA with nested markers" do
      cdata_text = "]]>]]>]]>"
      doc = context.create_document
      cdata = doc.create_cdata(cdata_text)
      expect(cdata.to_xml).to include("]]]]><![CDATA[>]]]]><![CDATA[>]]]]><![CDATA[>")
    end

    it "handles comments with double hyphens" do
      comment_text = "-- test -- comment --"
      doc = context.create_document
      comment = doc.create_comment(comment_text)
      expect(comment.to_xml).not_to include("--")
      expect(comment.to_xml).to include("- - test - - comment - -")
    end

    it "handles invalid processing instruction content" do
      content = "?> invalid"
      doc = context.create_document
      pi = doc.create_processing_instruction("test", content)
      expect(pi.to_xml).not_to include("?>?>")
    end
  end

  describe "namespace edge cases" do
    it "handles default namespace changes" do
      xml = <<~XML
        <root xmlns="http://default1.org">
          <child xmlns="http://default2.org">
            <grandchild xmlns=""/>
          </child>
        </root>
      XML

      doc = context.parse(xml)
      grandchild = doc.at_xpath("//grandchild")
      expect(grandchild.namespace).to be_nil
    end

    it "handles recursive namespace definitions" do
      xml = <<~XML
        <root xmlns:a="http://a.org">
          <a:child xmlns:a="http://b.org">
            <a:grandchild/>
          </a:child>
        </root>
      XML

      doc = context.parse(xml)
      grandchild = doc.at_xpath("//a:grandchild", "a" => "http://b.org")
      expect(grandchild.namespace.uri).to eq("http://b.org")
    end
  end

  describe "attribute edge cases" do
    it "handles attributes with same local name but different namespaces" do
      xml = <<~XML
        <root xmlns:a="http://a.org" xmlns:b="http://b.org">
          <element a:id="1" b:id="2"/>
        </root>
      XML

      doc = context.parse(xml)
      element = doc.at_xpath("//element")
      expect(element["a:id"]).to eq("1")
      expect(element["b:id"]).to eq("2")
    end

    it "handles special attribute values" do
      doc = context.create_document
      element = doc.create_element("test")

      special_values = {
        "empty" => "",
        "space" => " ",
        "tabs_newlines" => "\t\n",
        "unicode" => "⚡",
        "entities" => "<&>'\"",
      }

      special_values.each do |name, value|
        element[name] = value
        expect(element[name]).to eq(value)
      end
    end
  end

  describe "document structure edge cases" do
    it "handles deeply nested elements" do
      doc = context.create_document
      current = doc.create_element("root")
      doc.add_child(current)

      1000.times do |i|
        nested = doc.create_element("nested#{i}")
        current.add_child(nested)
        current = nested
      end

      expect(doc.to_xml).to include("<nested999>")
    end

    it "handles large number of siblings" do
      doc = context.create_document
      root = doc.create_element("root")
      doc.add_child(root)

      1000.times do |i|
        child = doc.create_element("child")
        child.text = i.to_s
        root.add_child(child)
      end

      expect(root.children.size).to eq(1000)
    end

    it "handles mixed content with all node types" do
      doc = context.create_document
      root = doc.create_element("root")
      doc.add_child(root)

      root.add_child("text1")
      root.add_child(doc.create_comment("comment"))
      root.add_child("text2")
      root.add_child(doc.create_cdata("<tag>"))
      root.add_child(doc.create_element("child"))
      root.add_child("text3")
      root.add_child(doc.create_processing_instruction("pi", "data"))

      expect(root.children.size).to eq(7)
    end
  end
end
