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
    require 'sass'

    def parse(parser, source_io)
      parser.style
    end

    def post_parse(parser, source_io)
      source_io = apply_preprocessor(parser.style_metadata['lang'], source_io)
      apply_scoping(parser.style_metadata['scoped'], source_io)
    end

    private

      def apply_preprocessor(language, source_io)
        case language
          when 'sass'
            Sass.compile(source_io, syntax: :sass)
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