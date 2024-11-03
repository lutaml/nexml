RSpec.describe "Adapter Examples" do
  let(:xml) { "<root><child>text</child></root>" }

  describe "Serialization consistency" do
    it "produces equivalent XML across adapters" do
      docs = [:nokogiri, :oga, :ox].map do |adapter|
        Moxml.new(adapter).parse(xml)
      end

      xmls = docs.map { |doc| normalize_xml(doc.to_xml) }
      expect(xmls.uniq.size).to eq(1)
    end

    private

    def normalize_xml(xml)
      xml.gsub(/>\s+</, "><")
         .gsub(/\s+/, " ")
         .gsub(/ >/, ">")
         .gsub(/\?></, "?>\n<")
         .strip
    end
  end
end
