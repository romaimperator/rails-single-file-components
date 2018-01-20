# frozen_string_literal: true
module RailsSingleFileComponents
  module RailsParts
    class MyRailtie < ::Rails::Railtie
      config.rails_single_file_components = ActiveSupport::OrderedOptions.new

      # Include the view helper lazily
      initializer 'rails_single_file_components.setup_view_helpers', after: :load_config_initializers, group: :all do |app|
        app.config.rails_single_file_components.component_path = 'app/components'

        ActiveSupport.on_load(:action_view) do
          include RailsSingleFileComponents::RailsParts::ViewHelpers
        end
      end

      initializer 'rails_single_file_components.monkey_patch_sass_importer', after: :setup_sass, group: :all do |app|
        module ::Sass
          module Rails
            class SassImporter < ::Sass::Importers::Filesystem
              # Duplicated from the parent class except for addition of sfc
              def extensions
                { 'sfc' => :sfc, 'css' => :scss }.merge(super)
              end

              alias_method :_old_find, :_find

              # Duplicated from the parent class except for the addition of processing with StyleTransformPipeline
              def _find(dir, name, options)
                full_filename, syntax = Sass::Util.destructure(find_real_file(dir, name, options))
                return _old_find(dir, name, options) unless syntax == :sfc

                return unless full_filename && File.readable?(full_filename)

                # TODO: this preserves historical behavior, but it's possible
                # :filename should be either normalized to the native format
                # or consistently URI-format.
                full_filename = full_filename.tr("\\", "/") if Sass::Util.windows?

                options[:syntax] = syntax
                options[:filename] = full_filename
                options[:importer] = self
                style_section = TransformPipelines::Style.new(File.read(full_filename), DataAttribute.compute(full_filename), false).transform
                Sass::Engine.new(style_section, options)
              end
            end
          end
        end
      end

      initializer 'rails_single_file_components.append_assets_path', group: :all do |app|
        app.config.paths.add "app/components", glob: "*.sfc"
        ActionController::Base.view_paths = ActionController::Base.view_paths + [RailsSingleFileComponents::RailsParts::SFCFileSystemResolver.new(
          Rails.root.join("app/components"),
          ":action{.sfc}",
        )]
        # ActionView::Template::Handlers.register_template_handler :sfc, ->(template) { RailsSingleFileComponents::TransformPipelines::Template.new(File.read(template), DataAttribute.compute(template)).transform }
        app.config.assets.paths.unshift('app/components')
        app.config.assets.paths.unshift(*app.config.paths['app/components'].existent_directories)
      end

      initializer 'rails_single_file_components.register_with_sprockets', group: :all do |app|
        module ::Sprockets
          register_mime_type 'text/single_file_component', extensions: ['.sfc']
          register_transformer 'text/single_file_component', 'text/sass', RailsSingleFileComponents::RailsParts::StyleProcessor
        end
      end
    end
  end
end
