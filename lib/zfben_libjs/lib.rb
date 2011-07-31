class String
  def partition_all(reg)
    r = self.partition(reg)
    if reg =~ r[2]
      r[2] = r[2].partition_all(reg)
    end
    return r.flatten
  end
end

def get_filetype path
  return File.extname(path).delete('.')
end

def download url, path
  if url =~ /:\/\// && (@config['download'] == true || !File.exists?(path))
    unless system 'wget ' + url + ' -O ' + path + ' -N'
      p url + ' download fail!'
      system('rm ' + path)
      exit!
    end
  else
    system "cp #{url} #{path}" if File.exists?(url) && url != path
  end
end

def css_import url, dir
  path = File.join(dir, File.basename(url))
  download url, path
  reg = /@import\s+\(?"([^"]+)"\)?;?/
  return File.read(path).partition_all(reg).map{ |f|
    if reg =~ f
      f = reg.match(f)[1]
      f = "/* @import #{f} */\n" + css_import(File.join(File.dirname(url), f), dir)
    end
    f
  }.join("\n")
end

def download_images lib, url, path
  reg = /url\("?'?([^'")]+)'?"?\)/
  return File.read(path).partition_all(reg).map{ |f|
    if reg =~ f
      f = reg.match(f)[1]
      sub = File.join(File.dirname(path), f)
      suburl = File.dirname(url) + '/' + f
      system('mkdir ' + File.dirname(sub)) unless File.exists?(File.dirname(sub))
      download(suburl, sub)
      f = sub
    else
      f = nil
    end
    f
  }.compact
end

def css2sass css
  return Sass::CSS.new(css, :cache => false).render(:sass)
end

def minify source, type
  if source.length > 10
    min = ''
    case type
      when :js
        min = Uglifier.compile(source, :copyright => false)
      when :css
        min = Sass::Engine.new(css2sass(source), { :syntax => :sass, :style => :compressed, :cache => false }).render
    end
    if min.length > 10
      return min
    end
  end
  return source
end
