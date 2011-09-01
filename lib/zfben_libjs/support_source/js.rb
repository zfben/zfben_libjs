class Zfben_libjs::Js < Zfben_libjs::Source

  def to_js
    compile
  end

  def before_minify
    @minified = Uglifier.compile(@source, :copyright => false)
  end

end
