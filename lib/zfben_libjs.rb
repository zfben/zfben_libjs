require 'rubygems'
require 'rainbow'
require 'json'
require 'compass'
require 'coffee-script'
require 'uglifier'
require 'yaml'
require 'sass/css'
require File.join(File.dirname(__FILE__), 'zfben_libjs', 'lib.rb')
  
def err msg
  STDERR.print "#{msg}\n".color(:red)
  exit!
end

def tip msg
  STDOUT.print "#{msg}\n".color(:green)
end

class Libjs
  def initialize config_file
    @config_file = File.exists?(config_file) ? [config_file] : Dir[config_file + '*']
    if @config_file.length == 0 || File.directory?(@config_file[0])
      err config_file + ' is not exist!'
    else
      @config_file = @config_file[0]
    end
    
    begin
      @data = YAML.load(File.read(@config_file))
    rescue => e
      err "#{@config_file} load filed!\n#{e}"
    end
    
    tip "#{@config_file} load success!"
    
    p @data
  end
  
  def build!
    print '== Starting Build @' + @config_file

    # Merge default config
    @config = {
      'src' => 'src',
      'download' => false,
      'minify' => true,
      'url' => ''
    }.merge(@data['config'])
    
    @config['src'] = File.join(File.dirname(@config_file), @config['src'])
    system('mkdir ' + @config['src']) unless File.exists?(@config['src'])
    
    ['source'].each do |path|
      @config['src/' + path] = File.join(@config['src'], '.' + path) unless @config.has_key?('src/' + path)
      system('mkdir ' + @config['src/' + path]) unless File.exists?(@config['src/' + path])
    end
    
    ['javascripts', 'stylesheets', 'images'].each do |path|
      @config['url/' + path] = @config['url'] + '/' + path unless @config.has_key?('url/' + path)
      @config['src/' + path] = File.join(@config['src'], path) unless @config.has_key?('src/' + path)
      system('mkdir ' + @config['src/' + path]) unless File.exists?(@config['src/' + path])
    end

    # Merge default libs
    @libs = {
      'lazyload' => 'https://raw.github.com/rgrove/lazyload/master/lazyload.js'
    }.merge(@data['libs'])
    
    @bundle = @data['bundle']
    
    @preload = @data['preload']
    
    if @config.has_key?('before')
      load @config['before']
    end
    
    
    p '== [1/2] Starting Progress Source =='
    length = @libs.length
    num = 0
    @libs.each do |name, urls|
      num = num + 1
      p "[#{num}/#{length}] #{name}"
      urls = [urls] unless urls.class == Array
      lib = []
      urls.each do |url|
        if @libs.has_key?(url)
          lib.push(url)
        else
          path = File.join(@config['src/source'], name, File.basename(url))
          dir = File.dirname(path)
          system('mkdir ' + dir) unless File.exists?(dir)
          download url, path
          case get_filetype(path)
            when 'css'
              css = css_import(url, dir)
              File.open(path, 'w'){ |f| f.write(css) }
              images = download_images(name, url, path)
              if images.length > 0
                lib.push images
              end
            when 'rb'
              script = eval(File.read(path))
              rb_path = path
              css = ''
              js = ''
              script.each do | type, content |
                case type
                  when :css
                    css << content
                  when :js
                    js << content
                end
              end
              if css != ''
                path = File.join(dir, File.basename(path, '.rb') << '.css')
                File.open(path, 'w'){ |f| f.write("/* @import #{rb_path} */\n" + css) }
              elsif js != ''
                path = File.join(dir, File.basename(path, '.rb') << '.js')
                File.open(path, 'w'){ |f| f.write("/* @import #{rb_path} */\n" + js) }
              end
            when 'sass'
              options = { :syntax => :sass, :cache => false }.merge(Compass.sass_engine_options)
              options[:load_paths].push File.dirname(path), File.dirname(url)
              css = "/* @import #{path} */\n" + Sass::Engine.new(File.read(path), options).render
              path = File.join(dir, File.basename(path, '.sass') << '.css')
              File.open(path, 'w'){ |f| f.write(css) }
            when 'scss'
              options = { :syntax => :scss, :cache => false }.merge(Compass.sass_engine_options)
              options[:load_paths].push File.dirname(path), File.dirname(url)
              css = "/* @import #{path} */\n" + Sass::Engine.new(File.read(path), options).render
              path = File.join(dir, File.basename(path, '.sass') << '.css')
              File.open(path, 'w'){ |f| f.write(css) }
            when 'coffee'
              js = "/* @import #{path} */\n" + CoffeeScript.compile(File.read(path))
              path = File.join(dir, File.basename(path, '.coffee') << '.js')
              File.open(path, 'w'){ |f| f.write(js) }
            else
              lib.push url
          end
          lib.push(path)
        end
      end
      lib = lib.flatten
      
      css = ''
      js = ''
      lib = lib.map{ |file|
        if File.exists?(file)
          content = "/* @import #{file} */\n" + File.read(file)
          case File.extname(file)
            when '.css'
              css << content
              file = nil
            when '.js'
              js << content << ';'
              file = nil
          end
        end
        file
      }.compact
      if css != ''
        file = File.join(@config['src/source'], name + '.css')
        File.open(file, 'w'){ |f| f.write(css) }
        lib.push(file)
      end
      if js != ''
        file = File.join(@config['src/source'], name + '.js')
        File.open(file, 'w'){ |f| f.write(js) }
        lib.push(file)
      end
      
      @libs[name] = lib.map{ |file|
        if File.exists?(file)
          case File.extname(file)
            when '.js'
              type = 'javascripts'
            when '.css'
              type = 'stylesheets'
            else
              type = 'images'
          end
          
          path = File.join(@config['src/' + type], File.basename(file))
          
          p '=> ' + path
          
          system('cp ' + file + ' ' + path)
          
          reg = /url\("?'?([^'")]+)'?"?\)/
          if type == 'stylesheets' && @config['changeImageUrl'] && reg =~ File.read(path)
            css = File.read(path).partition_all(reg).map{ |f|
              if reg =~ f
                if @config['url'] == ''
                  f = 'url("../images/' << File.basename(f.match(reg)[1]) << '")'
                else
                  f = 'url("' + @config['url/images'] + File.basename(f.match(reg)[1]) << '")'
                end
              end
              f
            }.join('')
            File.open(path, 'w'){ |f| f.write(css) }
          end
          if type == 'images'
            path = nil
          end
          
          if @config['minify']
            if type == 'stylesheets'
              min = minify(File.read(path), :css)
              File.open(path, 'w'){ |f| f.write(min) }
            end
            if type == 'javascripts'
              min = minify(File.read(path), :js)
              File.open(path, 'w'){ |f| f.write(min) }
            end
          end
        else
          path = @libs[file]
        end
        path
      }.compact.flatten.uniq
      @libs[name] = @libs[name][0] if @libs[name].length == 1
    end
    
    p '== [2/2] Generate lib.js =='
    
    libjs = File.read(@libs['lazyload']) << ';'
    
    libjs_core = CoffeeScript.compile(File.read(File.join(File.dirname(__FILE__), 'zfben_libjs', 'lib.coffee')))

    libjs << (@config['minify'] ? minify(libjs_core, :js) : @config['minify'])
    
    @urls = {}
    @libs.each do |lib, path|
      path = [path] unless path.class == Array
      path = path.map{ |url|
        case File.extname(url)
          when '.css'
            url = @config['url/stylesheets'] + '/' + File.basename(url)
          when '.js'
            url = @config['url/javascripts'] + '/' + File.basename(url)
          else
            url = nil
        end
        url
      }.compact.uniq
      @urls[lib] = path
    end
    
    libjs << "\n/* libs */\nlib.libs(#{@urls.to_json});"
    
    if @bundle != nil && @bundle.length > 0
      @bundle.each do |name, libs|
        css = ''
        js = ''
        files = []
        libs.each do |lib|
          lib = @libs[lib] if @libs.has_key?(lib)
          lib = [lib] unless lib.class == Array
          lib.each do |file|
            files.push(file)
            case File.extname(file)
              when '.css'
                css << File.read(file)
              when '.js'
                js << File.read(file) << ';'
            end
          end
        end
        
        path = []
        
        if css != ''
          file = File.join(@config['src/stylesheets'], name + '.css')
          File.open(file, 'w'){ |f| f.write(css) }
          path.push(@config['url/stylesheets'] + '/' + File.basename(file))
        end
        
        if js != ''
          files_url = files.map{ |f| @config['url/javascripts'] + '/' + File.basename(f) }.join("','")
          js << "\nif(typeof lib === 'function'){lib.loaded('add', '#{files_url}');}"
          file = File.join(@config['src/javascripts'], name + '.js')
          File.open(file, 'w'){ |f| f.write(js) }
          path.push(@config['url/javascripts'] + '/' + File.basename(file))
        end
        
        if path.length > 0
          path = path[0] if path.length == 0
          @bundle[name] = path
        else
          @bundle.delete(name)
        end
      end
      
      libjs << "\n/* bundle */\nlib.libs(#{@bundle.to_json});"
    end
    
    if @preload.class == Array && @preload.length > 0
      libjs << "\n/* preload */\nlib('#{@preload.join(' ')}');"
    end
    File.open(File.join(@config['src/javascripts'], 'lib.js'), 'w'){ |f| f.write(libjs) }
    
    if @config.has_key?('after')
      load @config['after']
    end
    
    p '== End Build =='
  end
end
