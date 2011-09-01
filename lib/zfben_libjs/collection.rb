class Zfben_libjs::Collection
  attr_accessor :name, :sources, :options, :css, :js, :images, :css_path, :js_path, :images_path
  
  def initialize name, sources, libs, options
    sources = [sources] unless sources.class.to_s != 'Array'
    @name = name
    
    @sources = sources.flatten.uniq.compact
    
    @options = options
    
    @css = []
    @js = []
    @images = []
    
    process_sources @sources, libs
  end
  
  def write_files!
    if @images.length > 0
      @images_path = @images.map{ |path|
        new_path = File.join(@options['src/images'], File.basename(path))
        FileUtils.cp path, new_path
        new_path
      }.uniq
    end
    
    merge_css = ''
    @css.each do |css|
      merge_css << css.to_css
    end
    if merge_css != ''
      @css_path = File.join(@options['src/stylesheets'], @name + '.css')
      css = Zfben_libjs::Css.new(:source => merge_css, :options => @options)
      if @options['changeImageUrl']
        css.change_images_url!
      end
      if @options['minify']
        #File.open(@css_path + '.debug', 'w'){ |f| f.write(merge_css) }
        file_content = css.minify
      else
        file_content = css.compile
      end
      File.open(@css_path, 'w'){ |f| f.write(file_content) }
    else
      @css_path = nil
    end
    
    merge_js = ''
    @js.each do |js|
      merge_js << js.to_js + ';'
    end
    if merge_js != ''
      @js_path = File.join(@options['src/javascripts'], @name + '.js')
      if @options['minify']
        #File.open(@js_path + '.debug', 'w'){ |f| f.write(merge_js) }
        merge_js = Zfben_libjs::Js.new(:source => merge_js).minify
      end
      File.open(@js_path, 'w'){ |f| f.write(merge_js) }
    else
      @js_path = nil
    end
    
    return [@css_path, @js_path].compact
  end
  
  private
  
  def process_sources sources, libs
    sources.each do |source|
      if libs.has_key?(source)
        process_sources libs[source], libs
      elsif source.respond_to?(:to_css)
        @css.push source
        @images = @images + source.images if source.respond_to?(:images)
      elsif source.respond_to?(:to_js)
        @js.push source
      end
    end
  end
end
