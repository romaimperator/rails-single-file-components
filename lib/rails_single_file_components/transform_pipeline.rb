module RailsSingleFileComponents
  class TransformPipeline
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

    def parse(source_io)
      fail NotImplementedError
    end

    def post_parse(source_io)
      source_io
    end
  end

  class TemplateTransformPipeline < TransformPipeline
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
        node[@data_attribute] = ""
      end
      document.to_html
    end
  end

  class StyleTransformPipeline < TransformPipeline
    class Converter < Sass::Tree::Visitors::Convert
      def self.visit(root, options, format, id)
        new(options, format, id).send(:visit, root)
      end

      def initialize(options, format, id)
        super(options, format)
        @id = id
      end

      def visit_rule(node)
        byebug
        rule = node.parsed_rules ? [node.parsed_rules.to_s] : node.rule
        if @format == :sass
          name = selector_to_sass(rule)
          name = "\\" + name if name[0] == ?:
          name.gsub(/^/, tab_str) + @id + yield
        elsif @format == :scss
          name = selector_to_scss(rule)
          res = name + yield
          if node.children.last.is_a?(Sass::Tree::CommentNode) && node.children.last.type == :silent
            res.slice!(-3..-1)
            res << "\n" << tab_str << "}\n"
          end
          res
        end
      end
    end

    require 'sass'

    def parse(parser, source_io)
      parser.style
    end

    def post_parse(parser, source_io)
      source_io = apply_preprocessor(parser.style_metadata['lang'], source_io)
      # apply_scoping(parser.style_metadata['scoped'], source_io)
    end

    private

      def apply_preprocessor(language, source_io)
        case language
          when 'sass'

            # Sass.compile(source_io, syntax: :sass)
            engine = Sass::Engine.new(source_io)
            tree = engine.to_tree
            conv = Converter.visit(tree, {}, :sass, "[#{@data_attribute}]")
            byebug
            conv
          when 'scss'
            Sass.compile(source_io, syntax: :scss)
          else
            source_io
        end
      end

      def apply_scoping(scoped, source_io)
        if scoped
          source_io.gsub(/([[:space:]]*[{]|[[:space:]]*,)/, "[#{@data_attribute}]\\1")
        else
          source_io
        end
      end
  end
end