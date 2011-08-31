module Zfben_libjs

  def self.get_source filepath, *options
    type = File.extname(filepath).delete('.')

    class_name = type.capitalize
    if Zfben_libjs.const_defined?(class_name, false)
      source_class = Zfben_libjs.const_get(class_name)
    else
      raise Exception.new(class_name + ' isn\'t exists!')
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

      if remote?
        download!
      end

      @source = @source || File.read(@filepath)

      after_initialize if self.respond_to?(:after_initialize)
    end

    def remote?
      return /^https?:\/\// =~ @filepath
    end

    def download!
      @remote_path = @filepath
      @filepath = File.join(@options['src/source'], '.download', File.basename(@remote_path))
      FileUtils.mkdir(File.dirname(@filepath)) unless File.exists?(File.dirname(@filepath))
      unless system 'wget ' + @remote_path + ' -O ' + @filepath
        FileUtils.rm @filepath
        raise Exception.new(@remote_path + ' download failed!')
      end
    end

    def name
      self.class.to_s.downcase.gsub(/Zfben_libjs::/, '')
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
  end

end
