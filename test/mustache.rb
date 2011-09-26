class Zfben_libjs::Mustache < Zfben_libjs::Source
  def after_initialize
    @source = "this['#{File.basename(@filepath, '.mustache')}']=(data)->Mustache.to_html('''#{@source}''', data)"
  end
  
  def compile
    Zfben_libjs::Coffee.new(:source => @source).compile
  end
  
  def to_js
    compile
  end
  
  def minify
    @minified = Zfben_libjs::Js.new(:source => @source).minify
  end
end
