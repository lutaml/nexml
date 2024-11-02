RSpec.describe "Memory Usage Examples" do
  let(:context) { Moxml.new }

  describe "Memory efficient processing" do
    it "processes large documents efficiently" do
      # Create large document
      doc = context.create_document
      root = doc.create_element("root")
      doc.add_child(root)

      1000.times do |i|
        node = doc.create_element("large-node")
        node.add_child(doc.create_text("Content #{i}"))
        root.add_child(node)
      end

      # Process and remove nodes
      memory_before = GetProcessMem.new.mb
      doc.xpath("//large-node").each do |node|
        node.remove
        node = nil
      end
      GC.start
      memory_after = GetProcessMem.new.mb

      expect(memory_after).to be <= memory_before
      expect(doc.xpath("//large-node")).to be_empty
    end

    it "handles streaming processing" do
      # Create temp file
      file = Tempfile.new(["test", ".xml"])
      begin
        file.write("<root><item>data</item></root>")
        file.close

        # Process file
        doc = nil
        File.open(file.path) do |f|
          doc = context.parse(f)
          expect(doc.at_xpath("//item").text).to eq("data")
          doc = nil
        end
        GC.start

        expect(doc).to be_nil
      ensure
        file.unlink
      end
    end
  end
end
