module RailsSingleFileComponents
  module RailsParts
    class MyRailtie < ::Rails::Railtie
      config.rails_single_file_components = ActiveSupport::OrderedOptions.new
      # Include the view helper lazily
      initializer 'rails_single_file_components.setup_view_helpers', after: :load_config_initializers, group: :all do |app|
        app.config.rails_single_file_components.component_path = 'app/components'

        ActiveSupport.on_load(:action_controller) do
        end

        ActiveSupport.on_load(:action_view) do
          include RailsSingleFileComponents::RailsParts::ViewHelpers
        end
      end

      initializer 'rails_single_file_components.add_sass_importer', after: :setup_sass, group: :all do |app|
        module ::Sass
          module Rails
            class SassImporter < ::Sass::Importers::Filesystem
              def extensions
                { 'sfc' => :sfc, 'css' => :scss }.merge(super)
              end

              def _find(dir, name, options)
                full_filename, syntax = Sass::Util.destructure(find_real_file(dir, name, options))
                return unless full_filename && File.readable?(full_filename)

                # TODO: this preserves historical behavior, but it's possible
                # :filename should be either normalized to the native format
                # or consistently URI-format.
                full_filename = full_filename.tr("\\", "/") if Sass::Util.windows?

                options[:syntax] = syntax
                options[:filename] = full_filename
                options[:importer] = self
                style_section = StyleTransformPipeline.new(File.read(full_filename), DataAttribute.compute(full_filename)).transform
                Sass::Engine.new(style_section, options)
              end
            end
          end
        end
      end

      initializer 'rails_single_file_components.append_assets_path', group: :all do |app|
        app.config.paths.add "app/components", glob: "*.sfc"
        app.config.assets.paths.unshift('app/components')
        app.config.assets.paths.unshift(*app.config.paths['app/components'].existent_directories)
      end
    end
  end
end

module Sprockets
  register_mime_type 'text/single_file_component', extensions: ['.sfc']
  register_transformer 'text/single_file_component', 'text/sass', RailsSingleFileComponents::RailsParts::StyleProcessor
end

# app/assets/stylesheets/components.css.erb
#<%= styles %>