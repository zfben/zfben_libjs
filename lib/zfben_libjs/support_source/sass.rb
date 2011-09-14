class Zfben_libjs::Sass < Zfben_libjs::Source
  def after_initialize
    @options = @options.merges({ :syntax => :sass, :cache => false }, Compass.sass_engine_options)
    @options[:load_paths].push File.dirname(@filepath)
    @source = "@import compass\n" + @source
  end

  def to_css
    compile
  end

  def before_compile
    @compiled = Sass::Engine.new(@source, @options).render
  end

  def before_minify
    @minified = Zfben_libjs::Css.new(:source => @compiled, :options => @options).minify
  end
end
