module Moxml
  class ProcessingInstruction < Node
    def target
      adapter.processing_instruction_target(@native)
    end

    def target=(new_target)
      adapter.set_processing_instruction_target(@native, new_target)
      self
    end

    def content
      adapter.processing_instruction_content(@native)
    end

    def content=(new_content)
      adapter.set_processing_instruction_content(@native, new_content)
      self
    end

    def processing_instruction?
      true
    end
  end
end
