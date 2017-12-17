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
        RailsSingleFileComponents::TemplateTransformPipeline.new(template, matches.first, self).transform.html_safe
      end
    end
  end
end
