# frozen_string_literal: true
module RailsSingleFileComponents
  module TransformPipelines
    class Template < Base
      def initialize(source_io, filename)
        super(source_io, filename)
      end

      def parse(parser, source_io)
        parser.template
      end

      def post_parse(parser, source_io)
        [apply_scoping_data_attributes(source_io), parser.template_metadata['lang']]
      end

      private

      def apply_scoping_data_attributes(source_io)
        source_io.gsub(/(<\w+)/, "\\1 #{@data_attribute} ")
      end
    end
  end
end