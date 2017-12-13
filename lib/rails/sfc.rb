module RailsSingleFileComponents
  class Plugin
    def handles_encoding?
      true
    end

    def self.call(template)
      new.call(template)
    end

    def call(template)
      template_part = template.source.match(%r'<template>\n[[:blank:]]*(.*)\n</template>'m)[1]
      "_buf = String.new; _buf << '#{template_part}'; _buf.to_s"
    end
  end
end

ActionView::Template.register_template_handler :sfc, RailsSingleFileComponents::Plugin
