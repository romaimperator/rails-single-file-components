module RailsSingleFileComponents
  class AssetCompilation
    def initialize(live_compilation)
      @live_compilation = live_compilation
      Dir.mkdir(Rails.root.join('public', 'components')) if !Dir.exist?(Rails.root.join('public', 'components'))
    end

    def compile
      if @live_compilation
        components = Dir["#{Rails.root.join(Rails.application.config.rails_single_file_components.component_path)}/**/*.sfc"]
        styles = []
        components.each do |filename|
          File.open(filename, 'r') do |f|
            styles << StyleTransformPipeline.new(f.read, DataAttribute.compute(filename)).transform
          end
        end
        styles = styles.join("\n")
        stylesheet_path = Rails.root.join('public', 'components', "rails_single_file_components.self-#{Digest::MD5.hexdigest(styles)}.css")
        File.open(stylesheet_path, 'wb') do |f|
          f.write(styles)
        end
      end
      "components/rails_single_file_components.self-#{Digest::MD5.hexdigest(styles)}.css"
    end
  end
end