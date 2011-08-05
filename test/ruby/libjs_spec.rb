require File.realpath(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'zfben_libjs.rb'))
SPEC_PATH = File.realpath(File.dirname(__FILE__))

describe Libjs do
  it "when pass nothing to Libjs.new" do
    begin
      Libjs.new
    rescue => e
      e.message
    end
  end
  it "when pass a filename to Libjs.new" do
    Libjs.new(File.join(SPEC_PATH, 'spec'))
  end
end
