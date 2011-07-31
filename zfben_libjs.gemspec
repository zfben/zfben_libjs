# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "zfben_libjs/version"

Gem::Specification.new do |s|
  s.name        = "zfben_libjs"
  s.version     = ZfbenLibjs::VERSION
  s.authors     = ["Ben"]
  s.email       = ["ben@zfben.com"]
  s.homepage    = ""
  s.summary     = %q{}
  s.description = %q{}

  s.rubyforge_project = "zfben_libjs"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency 'rainbow'
  s.add_dependency 'json'
  s.add_dependency 'therubyracer'
  s.add_dependency 'coffee-script'
  s.add_dependency 'uglifier'
  s.add_dependency 'compass'
  s.add_dependency 'sinatra'
  s.add_dependency 'watchr'
end
