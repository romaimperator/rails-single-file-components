# frozen_string_literal: true
module RailsSingleFileComponents
  # ParsedTemplate = Struct.new(:source, :lang, :scoped?)
  ParsedStyle = Struct.new(:source, :lang, :scoped?)

  class Parser
    attr_reader :xml_source

    def initialize(source_io)
      @source_io = source_io
      @xml_source = Nokogiri::HTML.fragment(source_io.strip)
    end

    def template
      @template ||= begin
        match_data = /<template[^>]*>(.*)<\/template>/m.match(@source_io).captures
        match_data.first || ""
      end
    end

    def template_metadata
      @template_metadata ||= tag_attributes(tag('template'))
    end

    def styles
      @styles ||= tag('style').map do |tag|
        ParsedStyle.new(
            source: tag_content(tag),
            lang: tag_attributes(tag)['lang'],
            scoped?: !!tag_attributes(tag)['scoped']
        )
      end
    end

    private

      def tag(tag_name)
        @xml_source.at_xpath(tag_name)
      end

      def tag_content(tag)
        if tag
          tag.children.to_html
        else
          ""
        end
      end

      def tag_attributes(tag)
        if tag
          Hash[tag.attributes.map { |k, v| [k, v.to_s] }]
        else
          {}
        end
      end
  end
end