class Zfben_libjs::Css < Zfben_libjs::Source

  REGEXP_REMOTE_CSS = /@import[^"]+"([^"]+)"\)?;?/
  REGEXP_REMOTE_IMAGE = /url\("?'?([^'")]+)'?"?\)/
  
  def after_initialize
    @options = @options.merge({ :syntax => :sass, :style => :compressed, :cache => false })
    
    @images = []

    if @remote_path || @filepath
      remote_url = File.dirname(@remote_path || @filepath)
      @source = import_remote_css @source, remote_url
      download_images! remote_url
    end
  end
  
  def images
    @images
  end

  def to_css
    compile
  end

  def to_sass
    Sass::CSS.new(@source, @options).render(:sass)
  end

  def to_scss
    Sass::CSS.new(@source, @options).render(:scss)
  end

  def before_minify
    @minified = Sass::Engine.new(to_sass, @options).render
  end
  
  def change_images_url!
    @source = @source.partition_all(REGEXP_REMOTE_IMAGE).map{ |line|
      if REGEXP_REMOTE_IMAGE =~ line
        path = line.match(REGEXP_REMOTE_IMAGE)[1]
        filename = File.basename(path)
        if File.exists?(File.join(@options['src/images'], filename))
          if @options['url'] == ''
            url = '../images/' + filename
          else
            url = @options['url/images'] + '/' + filename
          end
          line = 'url("' << url << '")'
        end
      end
      line
    }.join ''
  end
  
  private
  
  def import_remote_css source, remote_url
    return source.partition_all(REGEXP_REMOTE_CSS).map{ |f|
      if REGEXP_REMOTE_CSS =~ f
        url = REGEXP_REMOTE_CSS.match(f)[1]
        unless File.exists?(url)
          url = File.join(remote_url, url)
          path = File.join(@options['src/source'], '.download', File.basename(url))
          download(url, path)
        else
          path = url
        end
        f = import_remote_css(File.read(path), File.dirname(url))
      end
      f
    }.join("\n")
  end
  
  def download_images! remote_url
    @source = @source.partition_all(REGEXP_REMOTE_IMAGE).map{ |line|
      if REGEXP_REMOTE_IMAGE =~ line
        url = REGEXP_REMOTE_IMAGE.match(line)[1]
        path = File.join(@options['src/source'], '.download', self.name + '_' + File.basename(url))
        unless File.exists?(url) && File.exists?(path)
          url = File.join(remote_url, url)
          download(url, path)
        else
          path = url
        end
        @images.push path
        line = 'url(../' + File.basename(path) + ')'
      end
      line
    }.join("\n")
  end
end
