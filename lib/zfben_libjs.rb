require 'zfben_libjs/version'
require 'bundler/setup'
Bundler.require
require 'yaml'
require 'sass/css'

class Libjs
  def initialize config_file
    unless File.exists?(config_file)
      STDERR.print "#{config_file} is not exist!\n".color(:red)
    end
  end
end
