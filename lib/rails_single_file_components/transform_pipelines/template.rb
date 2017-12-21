# frozen_string_literal: true
module RailsSingleFileComponents
  module TransformPipelines
    class Template < Base
      def initialize(source_io, filename, view)
        super(source_io, filename)
        @view = view
      end

      def parse(parser, source_io)
        parser.template
      end

      def post_parse(parser, source_io)
        source_io = apply_preprocessor(parser.template_metadata['lang'], source_io)
        apply_scoping_data_attributes(source_io)
      end

      private

      def apply_preprocessor(language, source_io)
        @view.render inline: source_io, type: language || :erb
      end

      def apply_scoping_data_attributes(source_io)
        document = Nokogiri::HTML.fragment(source_io)
        document.traverse do |node|
          node[@data_attribute] = ''
        end
        document.to_html
      end
    end
  end
end