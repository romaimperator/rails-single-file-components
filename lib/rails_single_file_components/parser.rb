module RailsSingleFileComponents
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
      @template_metadata ||= tag_attributes('template')
    end

    def style
      @style ||= tag_content('style')
    end

    def style_metadata
      @style_metadata ||= tag_attributes('style')
    end

    private

      def tag(tag_name)
        @xml_source.at_xpath(tag_name)
      end

      def tag_content(tag_name)
        tag = tag(tag_name)
        if tag
          tag.children.to_html
        else
          ""
        end
      end

      def tag_attributes(tag_name)
        tag = tag(tag_name)
        if tag
          Hash[tag.attributes.map { |k, v| [k, v.to_s] }]
        else
          {}
        end
      end
  end
end