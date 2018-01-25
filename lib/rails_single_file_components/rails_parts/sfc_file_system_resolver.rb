require 'action_view/template/resolver'

module RailsSingleFileComponents
  module RailsParts
    class DataAttributingTemplate < ::ActionView::Template
      def initialize(source, identifier, handler, details, data_attribute)
        super(source, identifier, handler, details)
        @data_attribute = data_attribute
      end

      def render(*args)
        full_template = super
        full_template.gsub(/(<\w+)/, "\\1 #{@data_attribute} ").html_safe
      end
    end

    class SFCFileSystemResolver < ActionView::FileSystemResolver
      def build_query(path, details)
        query = @pattern.dup

        prefix = path.prefix.empty? ? "" : "#{escape_entry(path.prefix)}\\1"
        query.gsub!(/:prefix(\/)?/, prefix)

        # Removed the requirement for partials to have leading underscores since we are rendering other components
        partial = escape_entry(path.partial? ? "#{path.name}" : path.name)
        query.gsub!(/:action/, partial)

        details.each do |ext, candidates|
          if ext == :variants && candidates == :any
            query.gsub!(/:#{ext}/, "*")
          else
            query.gsub!(/:#{ext}/, "{#{candidates.compact.uniq.join(',')}}")
          end
        end

        File.expand_path(query, @path)
      end

      def query(path, details, formats, outside_app_allowed)
        query = build_query(path, details)

        template_paths = find_template_paths(query)
        template_paths = reject_files_external_to_app(template_paths) unless outside_app_allowed

        template_paths.map do |template|
          handler, format, variant = extract_handler_and_format_and_variant(template)

          # Override the format and handler based on the information from the template
          contents, format = RailsSingleFileComponents::TransformPipelines::Template.new(File.read(template), DataAttribute.compute(template)).transform
          handler = ActionView::Template.handler_for_extension(format)

          DataAttributingTemplate.new(contents, File.expand_path(template), handler,
                       {virtual_path: path.virtual,
                       format: format,
                       variant: variant,
                       updated_at: mtime(template)},
                       DataAttribute.compute(template)
          )
        end
      end

    end
  end
end
