# spec/moxml_spec.rb
RSpec.describe Moxml do
  it "has a version number" do
    expect(Moxml::VERSION).not_to be nil
  end

  describe ".configure" do
    it "allows setting backend" do
      Moxml.configure do |config|
        config.backend = :nokogiri
      end
      expect(Moxml.config.backend).to eq(:nokogiri)
    end

    it "allows setting CDATA options" do
      Moxml.configure do |config|
        config.cdata_sections = true
        config.cdata_patterns = ["script"]
      end
      expect(Moxml.config.cdata_sections).to be true
      expect(Moxml.config.cdata_patterns).to eq(["script"])
    end
  end
end
