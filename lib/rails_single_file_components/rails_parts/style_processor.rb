module RailsSingleFileComponents
  module RailsParts
    module StyleProcessor
      def self.call(input)
        pipeline = RailsSingleFileComponents::StyleTransformPipeline.new(input[:data], DataAttribute.compute(input[:filename])).transform
        { data: pipeline }
      end
    end
  end
end
