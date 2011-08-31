class Zfben_libjs::Coffee < Zfben_libjs::Source
  def to_js
    compile
  end

  def before_compile
    @compiled = CoffeeScript.compile(@source)
  end

  def before_minify
    @minified = Zfben_libjs::Js.new(:source => @source, :options => @options).minify
  end
end
