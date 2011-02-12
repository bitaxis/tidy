module ActionView
  
  class Base
    
    def tidy_javascripts
      @tidy_javascripts ||= []
      tidy_places.each do |javascript|
        @tidy_javascripts << javascript if File.exists? "#{Dir.pwd}/public/javascripts/#{javascript}.js"
      end
      @tidy_javascripts
    end

    def tidy_stylesheets
      @tidy_stylesheets ||= []
      tidy_places.each do |stylesheet|
        @tidy_stylesheets << stylesheet if File.exists? "#{Dir.pwd}/public/stylesheets/#{stylesheet}.css"
      end
      @tidy_stylesheets
    end
    
    private
    
    def tidy_places
      unless @tidy_places
        @tidy_places = ["#{controller.controller_path}/_controller", @tidy_template]
        @tidy_places.insert(0, @tidy_layout) if @tidy_layout
        @tidy_places << @tidy_partials if @tidy_partials
      end
      @tidy_places
    end
    
  end

  module Partials
    
    def _render_partial_with_capture(options, &block)
      @tidy_partials ||= []
      @tidy_partials << options[:partial] unless @tidy_partials.include?(options[:partial])
      _render_partial_without_capture(options, &block)
    end
    
    alias_method_chain :_render_partial, :capture
    
  end
  
  module Rendering
    
    def _render_template_with_capture(template, layout = nil, options = {})
      @tidy_template = template.virtual_path
      @tidy_layout = layout
      _render_template_without_capture(template, layout, options)
    end
    
    alias_method_chain :_render_template, :capture 
    
  end

end
