class Zfben_libjs::Css < Zfben_libjs::Source

  REGEXP_IMPORT_CSS = /@import\s+\(?"([^"]+)"\)?;?/
  
  def after_initialize
    @options = @options.merge({ :syntax => :sass, :style => :compressed, :cache => false })
    
    @source = import_remote_css @source
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
  
  private
  
  def import_remote_css url
    unless File.exists?(url)
      path = File.join(@options['src/source'], '.download', File.basename(url))
      download(url, path)
    else
      path = url
    end
    return File.read(path).partition_all(REGEXP_IMPORT_CSS).map{ |f|
      if REGEXP_IMPORT_CSS =~ f
        url = REGEXP_IMPORT_CSS.match(f)[1]
        f = import_remote_css(url)
      end
      f
    }.join("\n")
  end
end
