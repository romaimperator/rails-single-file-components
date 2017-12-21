# frozen_string_literal: true
module RailsSingleFileComponents
  module RailsParts
    module StyleProcessor
      def self.call(input)
        pipeline = TransformPipelines::Style.new(input[:data], DataAttribute.compute(input[:filename])).transform
        { data: pipeline }
      end
    end
  end
end
