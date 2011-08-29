class TestLibjs < Test::Unit::TestCase
  def test
    assert_equal Zfben_libjs::Libjs.new.opts, Zfben_libjs::Libjs.defaults
    assert_equal Zfben_libjs::Libjs.new('test').opts, Zfben_libjs::Libjs.new('t').opts
  end
end
