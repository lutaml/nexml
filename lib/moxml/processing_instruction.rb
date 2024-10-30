module Moxml
  class ProcessingInstruction < Node
    def initialize(target_or_native = nil, content = nil)
      case target_or_native
      when String
        super(adapter.create_processing_instruction(nil, target_or_native, content))
      else
        super(target_or_native)
      end
    end

    def target
      adapter.processing_instruction_target(native)
    end

    def target=(new_target)
      adapter.set_processing_instruction_target(native, new_target)
      self
    end

    def content
      adapter.processing_instruction_content(native)
    end

    def content=(new_content)
      adapter.set_processing_instruction_content(native, new_content)
      self
    end

    def blank?
      content.strip.empty?
    end

    def processing_instruction?
      true
    end

    private

    def create_native_node
      adapter.create_processing_instruction(nil, "", "")
    end
  end
end
