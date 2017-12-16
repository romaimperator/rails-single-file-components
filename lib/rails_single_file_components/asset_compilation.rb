require 'digest'
require 'sass'

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
        style_line = nil
        File.open(filename, 'r') do |f|
          current_line = ''
          until current_line =~ /<style/ || f.eof?
            current_line = f.readline
          end
          style_line = current_line
          source_styles = style_line + f.read
          _, source_styles = source_styles.split(/<style.*>/)
          if source_styles
            source_styles, _ = source_styles.split("</style>")
            source_styles.strip!
          end
        end
        if style_line =~ /sass/
          source_styles = Sass.compile(source_styles, syntax: :sass)
        elsif style_line =~ /scss/
          source_styles = Sass.compile(source_styles, syntax: :scss)
        end
        if style_line =~ /scoped/
          source_styles.gsub!(/([[:space:]]*[{]|[[:space:]]*,)/, "[data-sfc-#{Digest::MD5.hexdigest(Rails.root.join(filename).to_s)}]\\1")
        end
        source_styles
      end
  end
end