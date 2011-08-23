class Zfben_libjs::Libjs
  def initialize config_file
    @config_file = File.exists?(config_file) && !File.directory?(config_file) ? [config_file] : Dir[config_file + '*'].select{ |f| !File.directory?(f) }
    if @config_file.length == 0
      err config_file + ' is not exist!'
    else
      @config_file = @config_file[0]
    end
    
    begin
      @data = YAML.load(File.read(@config_file))
    rescue => e
      err "#{@config_file} load filed!\n#{e}"
    end
    
    @path_gem = File.realpath(File.join(File.dirname(__FILE__), 'zfben_libjs'))
    @path_lib = File.realpath('.')
    
    tip "#{@config_file} load success!"
  end
end
