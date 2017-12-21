module RailsSingleFileComponents
  module TransformPipelines
    class Style < Base
      class Converter < ::Sass::Tree::Visitors::Convert
        def self.visit(root, options, format, id)
          new(options, format, id).send(:visit, root)
        end

        def initialize(options, format, id)
          super(options, format)
          @id = id
        end

        def visit_rule(node)
          rule = if node.parsed_rules
                   [node.parsed_rules.to_s.split(',').join("#{@id},")]
                 else
                   node.rule
                 end
          if @format == :sass
            name = selector_to_sass(rule)
            name = "\\" + name if name[0] == ?:
            name.gsub(/^/, tab_str) + @id + yield
          elsif @format == :scss
            name = selector_to_scss(rule)
            res = name + yield
            if node.children.last.is_a?(::Sass::Tree::CommentNode) && node.children.last.type == :silent
              res.slice!(-3..-1)
              res << "\n" << tab_str << "}\n"
            end
            res
          end
        end
      end

      def parse(parser, source_io)
        parser.style
      end

      def post_parse(parser, source_io)
        apply_preprocessor(parser.style_metadata['lang'], source_io)
      end

      private

      def apply_preprocessor(language, source_io)
        sass_io = case language
                    when 'sass'
                      source_io
                    when 'scss'
                      ::Sass::CSS.new(Sass.compile(source_io)).render
                    else
                      ::Sass::CSS.new(source_io).render
                  end
        engine = ::Sass::Engine.new(sass_io)
        Converter.visit(engine.to_tree, {}, :sass, "[#{@data_attribute}]")
      end
    end
  end
end
