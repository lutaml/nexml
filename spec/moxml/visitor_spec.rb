# spec/visitor_spec.rb
RSpec.describe Moxml::Visitor do
  let(:xml) do
    <<~XML
      <root>
        <div class="content">text</div>
        <div data-type="special">data</div>
        <script>
          <![CDATA[var x = 1;]]>
        </script>
      </root>
    XML
  end

  let(:doc) { Moxml::Document.new(xml) }

  class TestVisitor
    include Moxml::Visitor

    attr_reader :visited_methods

    def initialize
      @visited_methods = []
    end

    visit "div.content", to: :process_content
    visit "*[data-type]", to: :process_data
    visit :cdata, in: "script", to: :process_script_cdata

    def process_content(element)
      @visited_methods << :process_content
    end

    def process_data(element)
      @visited_methods << :process_data
    end

    def process_script_cdata(cdata)
      @visited_methods << :process_script_cdata
    end
  end

  describe "node matching" do
    let(:visitor) { TestVisitor.new }

    before { doc.accept(visitor) }

    it "matches nodes to correct methods" do
      expect(visitor.visited_methods).to eq(
        [:process_content, :process_data, :process_script_cdata]
      )
    end
  end
end
