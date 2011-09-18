class Zfben_libjs::Libjs
  Lib_version = Time.now.strftime('?%s')
  Default_options = {
    :config => {
      
      'src' => 'src',

      'url' => '',
      
      'download' => false,
      'minify' => true,
      'changeImageUrl' => true
    },
    
    :support_source => [],
    
    :libs => {
      'lazyload' => 'https://raw.github.com/rgrove/lazyload/master/lazyload.js'
    },
    :bundle => {},
    :routes => {},
    :preload => {}
  }
  
  Default_options[:support_source] = Dir[File.join(File.dirname(__FILE__), 'support_source', '*.rb')]

  def initialize *options
    # recive path or hash options
    case options[0].class.to_s
      when 'String'
        opts = read_config_file(options[0])
      when 'Hash'
        opts = options[0]
      else
        opts = Default_options.clone
    end
    
    @opts = merge_and_convert_options(opts)

    if options[1].class.to_s == 'Hash'
      @opts = @opts.deep_merge(options[1])
    end
    
    @path_gem = File.realpath(File.dirname(__FILE__))
    
    # config
    FileUtils.mkdir(@opts[:config]['src']) unless File.exists?(@opts[:config]['src'])
    ['source', 'javascripts', 'images', 'stylesheets'].each do |path|
      key = 'src/' + path
      @opts[:config][key] = File.join(@opts[:config]['src'], path) unless @opts[:config].has_key?(key)
      FileUtils.mkdir(@opts[:config][key]) unless File.exists?(@opts[:config][key])
      @opts[:config]['url/' + path] = @opts[:config]['url'] + '/' + path unless @opts[:config].has_key?('url/' + path)
    end

    # Merge default libs
    @libs = {
      'lazyload' => 'https://raw.github.com/rgrove/lazyload/master/lazyload.js'
    }
    @libs = @libs.merge(@opts[:libs]) if @opts.has_key?(:libs)
  end
  
  def opts
    return @opts.clone
  end
  
  def self.defaults
    return Default_options.clone
  end
  
  private
  
  def read_config_file filepath
    config_file = File.exists?(filepath) && !File.directory?(filepath) ? [filepath] : Dir[filepath + '*'].select{ |f| !File.directory?(f) }
    if config_file.length == 0
      err filepath + ' is not exist!'
    end
    
    begin
      data = YAML.load(File.read(config_file[0]))
    rescue Exception => e
      data = {}
    end
    
    return data
  end
  
  def merge_and_convert_options opts
    options = Default_options.clone
    
    opts = opts.symbolize_keys
    
    [:config, :libs, :bundle, :routes, :preload, :support_source].each do |name|
      if opts.has_key?(name)
        case opts[name].class.to_s
          when 'Hash'
            opts[name]
            options[name] = options[name].merge(opts[name])
          when 'Array'
            opts[name] = [opts[name]] if opts[name].class.to_s != 'Array'
            options[name] = (options[name] + opts[name]).uniq
        end
      end
    end
    
    options[:support_source].each{ |f| require File.realpath(f) }
    
    return options
  end
end
