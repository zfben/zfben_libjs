class TestSource < Test::Unit::TestCase
  def test
    ['js', 'css', 'sass', 'scss', 'coffee'].each do |type|
      source = Zfben_libjs.get_source('test/support_filetype/' + type + '.' + type)
      assert_equal source.class.to_s.downcase, 'zfben_libjs::' + type
      p source.compile
      p source.minify

      ruby = Zfben_libjs.get_source('test/support_filetype/rb_' + type + '.rb')
      assert_equal ruby.class.to_s.downcase, 'zfben_libjs::' + type
      p ruby.compile
      p ruby.minify
    end
  end
end
