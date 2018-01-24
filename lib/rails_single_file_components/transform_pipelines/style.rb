# frozen_string_literal: true
module RailsSingleFileComponents
  module TransformPipelines
    class Style < Base
      def initialize(source_io, data_attribute, convert)
        super(source_io, data_attribute)
        @convert = convert
      end

      def parse(parser, source_io)
        parser.style
      end

      def post_parse(parser, source_io)
        source_io = apply_preprocessor(parser.style_metadata['lang'], source_io)
        apply_data_attribute(parser.style_metadata['lang'], source_io) if parser.style_metadata['scoped']
      end

      private

      def apply_preprocessor(language, source_io)
        case [language, @convert]
          when ['sass', false], ['sass', true]
            source_io
          when ['scss', false]
            source_io
          when ['scss', true]
            Sass::Tree::Visitors::Convert.visit(Sass::Engine.new(source_io, syntax: :scss).to_tree, {}, :sass)
          else
            ::Sass::CSS.new(source_io).render(:sass)
        end
      end

      def apply_data_attribute(language, source_io)
        if language == 'sass'
          source_io.split("\n").map do |sass_line|
            case sass_line
              when /[:@+$]/
                sass_line
              when /,/
                sass_line_parts = sass_line.split(",").map { |match| match.gsub(/([[:graph:]]+)/, "\\1[#{@data_attribute}]") }
                if sass_line_parts.size > 1
                  sass_line_parts.join(",")
                else
                  sass_line_parts.first + ","
                end
              when /[[:graph:]]+$/
                sass_line.gsub(/([[:graph:]]+)/, "\\1[#{@data_attribute}]")
              else
                sass_line
            end
          end.join("\n")
        else
          source_io.gsub(/([[:space:]]*[{]|[[:space:]]*,)/, "[#{@data_attribute}]\\1")
        end
      end
    end
  end
end
