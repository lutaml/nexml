# spec/moxml_spec.rb
RSpec.describe Moxml do
  it "has a version number" do
    expect(Moxml::VERSION).not_to be_nil
  end

  describe ".new" do
    it "creates a new context" do
      expect(Moxml.new).to be_a(Moxml::Context)
    end

    it "accepts adapter specification" do
      context = Moxml.new(:nokogiri)
      expect(context.config.adapter_name).to eq(:nokogiri)
    end

    it "raises error for invalid adapter" do
      expect { Moxml.new(:invalid) }.to raise_error(ArgumentError)
    end
  end
end
