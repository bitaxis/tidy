module ActionController

  class Base

    # Chain the render_for_file method so that we can capture the view template being rendered

    def render_for_file_with_capture(template, status = nil, layout = nil, locals = {})
      @rendered_template = template.path_without_format_and_extension
      render_for_file_without_capture(template, status, layout, locals)
    end

    alias_method_chain :render_for_file, :capture

  end

end

module ActionView

  module Partials

    # Chain the render_partial method so that we can capture all he partials being rendered as part of a view

    def render_partial_with_capture(options = {})
      @rendered_partials ||= []
      @rendered_partials << options[:partial] unless @rendered_partials.include?(options[:partial])
      render_partial_without_capture(options)
    end

    alias_method_chain :render_partial, :capture

  end

end

module ActionView

  class Base

    def tidy_javascripts
      @javascripts ||= []
      tidy_places.each do |javascript|
        @javascripts << javascript if File.exists? "#{Dir.pwd}/public/javascripts/#{javascript}.js"
      end
      @javascripts
    end

    def tidy_stylesheets
      @stylesheets ||= []
      tidy_places.each do |stylesheet|
        @stylesheets << stylesheet if File.exists? "#{Dir.pwd}/public/stylesheets/#{stylesheet}.css"
      end
      @stylesheets
    end

  private

    def rendered_view_and_template
      [template.name, "application", "#{controller.controller_path}/_controller", "#{@rendered_template}"]
    end

    def rendered_partials
      return [] unless @rendered_partials
      @rendered_partials.collect do |partial|
        parts = partial.split(Regexp.new(File::SEPARATOR))
        parts[-1].insert(0, "_")
        parts.insert(0, controller_name) if parts.length < 2
        parts.join(File::SEPARATOR)
      end
    end

    def tidy_places
      rendered_view_and_template + rendered_partials
    end

  end

end
