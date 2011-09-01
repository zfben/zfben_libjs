class Zfben_libjs::Libjs
  Lib_version = Time.now.strftime('?%s')
  Default_options = {
    :config => {
      
      'src' => 'src',
      'src/source' => 'src/.source',
      'src/javascripts' => 'src/javascripts',
      'src/images' => 'src/images',
      'src/stylesheets' => 'src/stylesheets',

      'url' => '',
      'url/javascripts' => '/javascripts',
      'url/images' => '/images',
      'url/stylesheets' => '/stylesheets',
      
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

  def initialize *opts
    
    # recive path or hash options
    case opts[0].class.to_s
      when 'String'
        opts = read_config_file(opts[0])
      when 'Hash'
        opts = opts[0]
      else
        opts = {}
    end
    
    @opts = merge_and_convert_options(opts)
    
    @path_gem = File.realpath(File.dirname(__FILE__))
    
    # config
    ['src', 'src/source', 'src/javascripts', 'src/images', 'src/stylesheets'].each do |path|
      FileUtils.mkdir(@opts[:config][path]) unless File.exists?(@opts[:config][path])
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
      err config_file + ' is not exist!'
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
            options[name] = (options[name] + opts[name]).uniq
        end
      end
    end
    
    options[:support_source].each{ |f| require f }
    
    return options
  end
end
