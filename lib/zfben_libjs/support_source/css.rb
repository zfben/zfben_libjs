class Zfben_libjs::Css < Zfben_libjs::Source
  def after_initialize
    @options = @options.merge({ :syntax => :sass, :style => :compressed, :cache => false })
  end

  def to_css
    @source
  end

  def to_sass
    Sass::CSS.new(@source, @options).render(:sass)
  end

  def to_scss
    Sass::CSS.new(@source, @options).render(:scss)
  end

  def download_images
    @source
  end

  def before_minify
    @minified = Sass::Engine.new(to_sass, @options).render
  end
end
