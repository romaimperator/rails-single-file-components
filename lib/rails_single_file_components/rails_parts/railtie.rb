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
    end
  end
end
