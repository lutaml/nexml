# spec/moxml/comment_spec.rb
RSpec.describe Moxml::Comment do
  let(:comment) { described_class.new("test comment") }

  describe "#new" do
    it "creates comment with content" do
      expect(comment.content).to eq("test comment")
    end
  end

  describe "#to_xml" do
    it "serializes to comment" do
      expect(comment.to_xml).to eq("<!--test comment-->")
    end
  end
end
