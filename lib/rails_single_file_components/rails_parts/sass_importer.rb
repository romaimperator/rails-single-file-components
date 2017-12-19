require 'sass'

module RailsSingleFileComponents
  module RailsParts
    class SassImporter < Sass::Rails::SassImporter
      def extensions
        byebug
        { sfc: 'sfc' }
      end

      def _find(dir, name, options)
        byebug
        full_filename, syntax = Sass::Util.destructure(find_real_file(dir, name, options))
        return unless full_filename && File.readable?(full_filename)

        # TODO: this preserves historical behavior, but it's possible
        # :filename should be either normalized to the native format
        # or consistently URI-format.
        full_filename = full_filename.tr("\\", "/") if Sass::Util.windows?

        options[:syntax] = syntax
        options[:filename] = full_filename
        options[:importer] = self
        style_section = StyleTransformPipeline.new(File.read(full_filename), DataAttribute.compute(filename)).transform
        Sass::Engine.new(style_section, options)
      end
    end
  end
end