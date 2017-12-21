# frozen_string_literal: true
module RailsSingleFileComponents
  module TransformPipelines
    class Base
      def initialize(source_io, data_attribute)
        @source_io = source_io
        @data_attribute = data_attribute
      end

      def transform
        after_pre_parse = pre_parse(@source_io)
        parser = Parser.new(after_pre_parse)
        post_parse(parser, parse(parser, after_pre_parse))
      end

      def pre_parse(source_io)
        source_io
      end

      def parse(parser, source_io)
        fail NotImplementedError
      end

      def post_parse(parser, source_io)
        source_io
      end
    end
  end
end
