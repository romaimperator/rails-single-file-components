# frozen_string_literal: true
module RailsSingleFileComponents
  module RailsParts
    module StyleProcessor
      def self.call(input)
        pipeline, lang = TransformPipelines::Style.new(input[:data], DataAttribute.compute(input[:filename]), true).transform
        { data: pipeline || '' }
      end
    end
  end
end
