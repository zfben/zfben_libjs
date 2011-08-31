class Zfben_libjs::Js < Zfben_libjs::Source

  def to_js
    compile
  end

  def before_minify
    Uglifier.compile(@source, :copyright => false)
  end

end
