require File.realpath(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'zfben_libjs.rb'))

describe Libjs do
  it "returns 0 for all gutter game" do
    Libjs.new
  end
end
