require 'digest'

module RailsSingleFileComponents
  class AssetCompilation
    def initialize
      Dir.mkdir(Rails.root.join('public', 'components')) if !Dir.exist?(Rails.root.join('public', 'components'))
    end

    def compile
      components = Dir["#{Rails.application.config.rails_single_file_components.component_path}/**/*.sfc"]
      styles = []
      components.each do |filename|
        styles << fetch_styles(filename)
      end
      styles = styles.join("\n")
      stylesheet_path = Rails.root.join('public', 'components', "rails_single_file_components.self-#{Digest::MD5.hexdigest(styles)}.css")
      File.open(stylesheet_path, 'wb') do |f|
        f.write(styles)
      end
      "components/rails_single_file_components.self-#{Digest::MD5.hexdigest(styles)}.css"
    end

    private

      def fetch_styles(filename)
        source_styles = nil
        File.open(filename, 'r') do |f|
          source_styles = f.read
          _, source_styles = source_styles.split(/<style.*>/)
          if source_styles
            source_styles, _ = source_styles.split("</style>")
            source_styles.strip!
          end
        end
        source_styles
      end
  end
end