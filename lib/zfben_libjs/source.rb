module Zfben_libjs

  def self.get_source filepath, *options
    type = File.extname(filepath).delete('.').capitalize

    if Zfben_libjs.const_defined?(type, false)
      source_class = Zfben_libjs.const_get(type)
    else
      raise Exception.new(type + ' isn\'t exists!')
    end

    return source_class.new :filepath => filepath, :options => options[0]
  end

  class Source
    attr_accessor :filepath, :source, :options, :compiled, :minified

    def initialize *opts
      [:filepath, :source, :options].each do |name|
        self.send(name.to_s + '=',  opts[0][name]) if opts[0].has_key?(name)
      end

      @options = {} if @options.nil?

      download! if remote?

      @source = @source || File.read(@filepath)

      after_initialize if self.respond_to?(:after_initialize)
    end

    def remote?
      return /^https?:\/\// =~ @filepath
    end

    def download!
      @remote_path = @filepath
      @filepath = File.join(@options['src/source'], '.download', File.basename(@remote_path))
      download @remote_path, @filepath
    end

    def type
      self.class.to_s.gsub(/Zfben_libjs::/, '').downcase
    end

    def compile
      before_compile if self.respond_to?(:before_compile)
      @compiled = @compiled || @source
    end

    def minify
      before_minify if self.respond_to?(:before_minify)
      @minified = @minified || @compiled || @source
      @minified = @minified.gsub(/\n/ , '')
    end
    
    private
    
    def download url, path
      if !File.exists?(path) || @options['download']
        dir = File.dirname(path)
        FileUtils.mkdir(dir) unless File.exists?(dir)
        unless system 'wget ' + url + ' -O ' + path
          FileUtils.rm path
          raise Exception.new(url + ' download failed!')
        end
      end
    end
    
  end

end
