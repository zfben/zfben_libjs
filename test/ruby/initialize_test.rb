class TestLibjs < Test::Unit::TestCase
  def test
    assert_equal Zfben_libjs::Libjs.new('test').opts, Zfben_libjs::Libjs.new('t').opts
    assert_equal Zfben_libjs::Libjs.new('test', :config => { 'minify' => false} ).opts[:config]['minify'], false
  end
end
