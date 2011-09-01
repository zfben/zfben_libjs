class TestBuild < Test::Unit::TestCase
  def test
    Zfben_libjs::Libjs.new('test').build!
  end
end
