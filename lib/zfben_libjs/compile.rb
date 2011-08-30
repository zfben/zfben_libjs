module ZfbenLibjs
  def Compile filepath, *options

  end

  Dir[File.join(File.dirname(__FILE__), 'compile', '*.rb')].each{ |f| require File.realpath(f) }
end
