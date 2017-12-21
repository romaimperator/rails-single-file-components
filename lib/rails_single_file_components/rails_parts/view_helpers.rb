module RailsSingleFileComponents
  module RailsParts
    module ViewHelpers
      def sfc_component(file, locals: {}, options: {}, &block)
        matches = Dir.glob(Rails.root.join(Rails.application.config.rails_single_file_components.component_path, "#{file}.sfc"))
        fail MissingComponentException.new("No component named #{file}.sfc found in #{Rails.application.config.rails_single_file_components.component_path}") if matches.empty?
        template = nil
        File.open(matches.first, 'r') do |f|
          template = f.read
        end
        RailsSingleFileComponents::TransformPipelines::Template.new(template, DataAttribute.compute(matches.first), self).transform.html_safe
      end
    end
  end
end
