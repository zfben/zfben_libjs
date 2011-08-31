class Zfben_libjs::Rb < Zfben_libjs::Source
  def self.new *options
    filepath = options[0][:filepath]
    if !filepath.nil?
      script = eval(File.read(filepath))
      class_name = script.keys[0].capitalize
      source = script.values[0]
      if Zfben_libjs.const_defined?(class_name, false)
        source_class = Zfben_libjs.const_get(class_name)
      else
        raise Exception.new(class_name + ' isn\'t exists!')
      end

      return source_class.new :filepath => filepath, :source => source, :options => options[0][:options]
    else
      raise Exception.new('filepath isn\'t exists!') 
    end
  end
end
