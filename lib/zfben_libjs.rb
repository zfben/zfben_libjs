require 'rubygems'
require 'fileutils'
require 'rainbow'
require 'json'
require 'compass'
require 'coffee-script'
require 'uglifier'
require 'yaml'
require 'sass/css'
require 'active_support/core_ext'

module Zfben_libjs
  class Libjs
  end

  class Compile
  end
end

['lib.rb', 'source.rb', 'initialize.rb', 'collection.rb', 'railtie.rb'].each { |f| require File.join(File.dirname(__FILE__), 'zfben_libjs', f) }
  
def err msg
  STDERR.print "#{msg}\n".color(:red)
  exit!
end

def tip msg
  STDOUT.print "#{msg}\n".color(:green)
end

class Zfben_libjs::Libjs
  def build!
    tip '== Starting Build'
     
    if @opts[:config].has_key?('before')
      load @opts[:config]['before']
    end
    tip '== [1/2] Starting Progress Source =='
    length = @libs.length
      num = 0
      @libs.each do |name, urls|
        num = num + 1
        tip "[#{num}/#{length}] #{name}"
        urls = [urls] unless urls.class == Array
        urls = urls.map{ |url|
          if url.include?('*')
            url = Dir[url]
          end
          url
        }.flatten.uniq.compact
        lib = []
        urls.each do |url|
          if @libs.has_key?(url) && name != url
            lib.push(url)
          else
            source = Zfben_libjs.get_source(url, @opts[:config])
            lib.push(source)
          end
        end
        lib = lib.flatten.uniq.compact
        
        collection = Zfben_libjs::Collection.new(lib, @libs)
        collection.merge!
        
        lib = []
        
        if collection.css.length > 0
          path = File.join(@opts[:config]['src/stylesheets'], name + '.css')
          File.open(path, 'w'){ |f| f.write(collection.merge_css) }
          lib.push path
        end
        
        if collection.js.length > 0
          path = File.join(@opts[:config]['src/javascripts'], name + '.js')
          File.open(path, 'w'){ |f| f.write(collection.merge_js) }
          lib.push path
        end
        
        if collection.image.length > 0
          lib.push collection.image
        end
        
        @libs[name] = lib.flatten.compact.uniq
      end
=begin
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
            
            path = File.join(@opts[:config]['src/' + type], File.basename(file))
            
            tip '=> ' + path
            
            system('cp ' + file + ' ' + path)
            
            reg = /url\("?'?([^'")]+)'?"?\)/
            if type == 'stylesheets' && @opts[:config]['changeImageUrl'] && reg =~ File.read(path)
              css = File.read(path).partition_all(reg).map{ |f|
                if reg =~ f
                  filename = File.basename(f.match(reg)[1])
                  if File.exists?(File.join(@opts[:config]['src/images'], filename))
                    if @opts[:config]['url'] == ''
                      url = '../images/' << File.basename(f.match(reg)[1])
                    else
                      url = @opts[:config]['url/images'] + File.basename(f.match(reg)[1])
                    end
                    f = 'url("' << url << '")'
                  end
                end
                f
              }.join('')
              File.open(path, 'w'){ |f| f.write(css) }
            end
            if type == 'images'
              path = nil
            end
            
            if @opts[:config]['minify']
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
=end
      tip '== [2/2] Generate lib.js =='
      
      libjs = File.read(@libs['lazyload'][0]) << ';'
      
      libjs_core = File.read(File.join(@path_gem, 'lib.coffee'))
      
      libjs_core = CoffeeScript.compile(libjs_core)

      libjs << libjs_core << ';'
      
      @urls = {}
     
      p @libs
      @libs.each do |lib, path|
        path = [path] unless path.class == Array
        path = path.map{ |url|
          case File.extname(url)
            when '.css'
              url = @opts[:config]['url/stylesheets'] + '/' + File.basename(url)
            when '.js'
              url = @opts[:config]['url/javascripts'] + '/' + File.basename(url)
            else
              url = nil
          end
          url
        }.compact.uniq
        @urls[lib] = path
      end
      
      libjs << "\n/* libs */\nlib.libs(#{@urls.to_json});lib.loaded('add', 'lazyload');"
      libjs << Time.now.strftime('lib.defaults.version = "?%s";')
      
      if @opts.has_key?(:bundle)
        bundle = {}
        @opts[:bundle].each do |name, libs|
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
            file = File.join(@opts[:config]['src/stylesheets'], name + '.css')
            File.open(file, 'w'){ |f| f.write(css) }
            path.push(@opts[:config]['url/stylesheets'] + '/' + File.basename(file))
          end
          
          if js != ''
            files_url = files.map{ |f| @opts[:config]['url/javascripts'] + '/' + File.basename(f) }.join("','")
            js << "\nif(typeof lib === 'function'){lib.loaded('add', '#{files_url}');}"
            file = File.join(@opts[:config]['src/javascripts'], name + '.js')
            File.open(file, 'w'){ |f| f.write(js) }
            path.push(@opts[:config]['url/javascripts'] + '/' + File.basename(file))
          end
          
          if path.length > 0
            path = path[0] if path.length == 0
            bundle[name] = path
          end
        end
        
        libjs << "\n/* bundle */\nlib.libs(#{bundle.to_json});"
      end
      
      if @opts.has_key?(:routes)
        routes = {}
        @opts[:routes].each do |path, lib_name|
          lib_name = lib_name.join ' ' if lib_name.class == Array
          routes[path] = lib_name
        end
        libjs << "\n/* routes */\nlib.routes('add', #{routes.to_json});"
      end
      
      if @opts.has_key?(:preload)
        preload = @opts[:preload].class == Array ? @opts[:preload] : [ @opts[:preload] ]
        libjs << "\n/* preload */\nlib('#{preload.join(' ')}');"
      end
      
      libjs = minify(libjs, :js) if @opts[:config]['minify']
      File.open(File.join(@opts[:config]['src/javascripts'], 'lib.js'), 'w'){ |f| f.write(libjs) }
      
      if @opts[:config].has_key?('after')
        load @opts[:config]['after']
      end
      
      tip '== End Build =='
    end
end
