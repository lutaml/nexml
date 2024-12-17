# frozen_string_literal: true

RSpec.shared_examples "README Examples" do
  describe "Quick Start example" do
    it "builds document as shown in README" do
      context = Moxml.new
      doc = context.create_document

      root = doc.create_element("book")
      doc.add_child(root)

      root.add_namespace("dc", "http://purl.org/dc/elements/1.1/")
      title = doc.create_element("dc:title")
      title.add_child(doc.create_text("XML Processing with Ruby"))
      root.add_child(title)

      expect(doc.to_xml).to include(
        '<book xmlns:dc="http://purl.org/dc/elements/1.1/">',
        "<dc:title>XML Processing with Ruby</dc:title>",
        "</book>"
      )
    end
  end

  describe "Complex document example" do
    it "builds document with all features" do
      doc = Moxml.new.create_document

      # Add declaration
      doc.add_child(doc.create_declaration("1.0", "UTF-8"))

      # Create root with namespace
      root = doc.create_element("library")
      root.add_namespace(nil, "http://example.org/library")
      root.add_namespace("dc", "http://purl.org/dc/elements/1.1/")
      doc.add_child(root)

      # Add books
      %w[Ruby XML].each do |title|
        book = doc.create_element("book")

        # Add metadata
        dc_title = doc.create_element("dc:title")
        dc_title.add_child(doc.create_text(title))
        book.add_child(dc_title)

        # Add description
        desc = doc.create_element("description")
        desc.add_child(doc.create_cdata("About #{title}..."))
        book.add_child(desc)

        root.add_child(book)
      end

      xml = doc.to_xml
      expect(xml).to include('<?xml version="1.0" encoding="UTF-8"?>')
      expect(xml).to include('<library xmlns="http://example.org/library" xmlns:dc="http://purl.org/dc/elements/1.1/">')
      expect(xml).to include("<dc:title>Ruby</dc:title>")
      expect(xml).to include("<![CDATA[About Ruby...]]>")
      expect(xml).to include("<dc:title>XML</dc:title>")
      expect(xml).to include("<![CDATA[About XML...]]>")
    end
  end

  describe "Error handling example" do
    it "handles errors as shown in README" do
      context = Moxml.new

      expect do
        context.parse("<invalid>")
      end.to raise_error(Moxml::ParseError)

      doc = context.parse("<root/>")
      expect do
        doc.xpath("///")
      end.to raise_error(Moxml::XPathError)
    end
  end

  describe "Thread safety example" do
    it "processes XML in thread-safe manner" do
      processor = Class.new do
        def initialize
          @mutex = Mutex.new
          @context = Moxml.new
        end

        def process(xml)
          @mutex.synchronize do
            doc = @context.parse(xml)
            doc.to_xml
          end
        end
      end.new

      result = processor.process("<root/>")
      expect(result).to include("<root></root>")
    end
  end
end
