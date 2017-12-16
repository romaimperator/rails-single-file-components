require 'digest'

module RailsSingleFileComponents
  module RailsParts
    module ViewHelpers
      def stylesheet_component_tag
        stylesheet_path = ::RailsSingleFileComponents::AssetCompilation.new.compile
        "<link rel=\"stylesheet\" media=\"all\" href=\"#{stylesheet_path}\" />".html_safe
      end

      def sfc_component(file, locals: {}, options: {}, &block)
        matches = Dir.glob(Rails.root.join(Rails.application.config.rails_single_file_components.component_path, "#{file}.html.sfc"))
        fail MissingComponentException.new("No component named #{file}.html.sfc found in #{Rails.application.config.rails_single_file_components.component_path}") if matches.empty?
        template = nil
        File.open(matches.first, 'r') do |f|
          template = f.read
        end
        attributes = /<template(.*)>/.match(template).captures.first
        possible_attributes = /([[:alnum:]]+)[=]?"(.*)?"/.match(attributes)
        parsed_attributes = Hash[possible_attributes.captures.each_slice(2).to_a] if possible_attributes
        _, template = template.split(/<template.*>/)
        template, _ = template.split('</template>')
        parsed_attributes ||= Hash.new
        rendered_template = render inline: template, type: parsed_attributes['lang']&.to_sym || :erb
        document = Nokogiri::XML.fragment(rendered_template.gsub("\n", "").strip)
        if document.children.length > 1
          fail CompilationException.new("Template #{file}.html.sfc contains more than one root.")
        else
          document.traverse do |node|
            node["data-sfc-#{Digest::MD5.hexdigest(matches.first)}"] = ""
          end
        end
        # template.strip!
        # template.html_safe
        document.to_xml.html_safe
      end
    end
  end
end
