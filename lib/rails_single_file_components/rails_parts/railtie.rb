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
  register_transformer 'text/single_file_component', 'text/css', RailsSingleFileComponents::RailsParts::StyleProcessor
end

# app/assets/stylesheets/components.css.erb
#<%= styles %>