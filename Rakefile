require 'rubygems'
require 'bundler/gem_tasks'
require 'zfben_hanoi'

namespace :test do
  desc "Runs all the JavaScript tests and collects the results"
  JavaScriptTestTask.new(:js) do |t|
    test_cases        = ENV['TESTS'] && ENV['TESTS'].split(',')
    browsers          = ENV['BROWSERS'] && ENV['BROWSERS'].split(',')
    sources_directory = File.expand_path(File.dirname(__FILE__) + "/src")

    t.setup(sources_directory, test_cases, browsers)
  end
  
  desc 'Runs all the Ruby tests'
  task :ruby do
    require File.realpath('lib/zfben_libjs.rb')
    require 'test/unit'
    Dir['test/ruby/*_test.rb'].each{ |f| require File.realpath(f) }
  end
end
