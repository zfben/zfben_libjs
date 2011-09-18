module('lib.js core');

test('lib', 3, function(){

  equal(typeof lib, 'function', 'lib is a function');
  
  equal(typeof lib.loaded, 'function', 'lib.loaded is a function');
  
  equal(typeof lib.libs, 'function', 'lib.libs is a function');
  
});

test('lib.loaded', 3, function(){

  deepEqual(lib.loaded(), {
    'http://code.jquery.com/jquery.min.js': true,
    'http://code.jquery.com/qunit/qunit-git.css': true,
    'http://code.jquery.com/qunit/qunit-git.js': true,
    '/callback.js': true,
    '/javascripts/lib.js': true,
    '/javascripts/lazyload.js': true
  }, 'lib.loaded files are ok');
  
  deepEqual(lib.loaded('add', 'test'), {
    'http://code.jquery.com/jquery.min.js': true,
    'http://code.jquery.com/qunit/qunit-git.css': true,
    'http://code.jquery.com/qunit/qunit-git.js': true,
    '/callback.js': true,
    '/javascripts/lib.js': true,
    '/javascripts/lazyload.js': true,
    'test': true
  }, "lib.loaded('add', 'test') has been added");
  
  deepEqual(lib.loaded('del', 'test'), {
    'http://code.jquery.com/jquery.min.js': true,
    'http://code.jquery.com/qunit/qunit-git.css': true,
    'http://code.jquery.com/qunit/qunit-git.js': true,
    '/callback.js': true,
    '/javascripts/lib.js': true,
    '/javascripts/lazyload.js': true
  }, "lib.loaded('del', 'test') has been deleted");

});

test('lib.libs', 6, function(){

  deepEqual(lib.libs(), {
    lazyload: ['/javascripts/lazyload.js'],
    support_filetype: [
      '/stylesheets/support_filetype.css',
      '/javascripts/support_filetype.js'
    ],
    unload: [ '/javascripts/unload.js' ],
    load_times: [ '/javascripts/load_times.js' ],
    route_string: [ '/javascripts/route_string.js' ],
    route_regexp: [ '/javascripts/route_regexp.js' ],
    jquery: [ '/javascripts/jquery.js' ],
    jqueryui: [ '/javascripts/jquery.js', '/stylesheets/jqueryui.css', '/javascripts/jqueryui.js' ]
  }, 'lib.libs is ok');
  
  equal(typeof lib.lazyload, 'function', 'lib.lazyload is a function');
  
  deepEqual(lib.libs({test: 'test'}), {
    lazyload: ['/javascripts/lazyload.js'],
    support_filetype: [
      '/stylesheets/support_filetype.css',
      '/javascripts/support_filetype.js'
    ],
    unload: [ '/javascripts/unload.js' ],
    load_times: [ '/javascripts/load_times.js' ],
    route_string: [ '/javascripts/route_string.js' ],
    route_regexp: [ '/javascripts/route_regexp.js' ],
    jquery: [ '/javascripts/jquery.js' ],
    jqueryui: [ '/javascripts/jquery.js', '/stylesheets/jqueryui.css', '/javascripts/jqueryui.js' ],
    test: 'test'
  }, "lib.libs({test: 'test'}) has been added");
  
  equal(typeof lib.test, 'function', 'lib.test is a function');
  
  deepEqual(lib.libs({test: null}), {
    lazyload: ['/javascripts/lazyload.js'],
    support_filetype: [
      '/stylesheets/support_filetype.css',
      '/javascripts/support_filetype.js'
    ],
    unload: [ '/javascripts/unload.js' ],
    load_times: [ '/javascripts/load_times.js' ],
    route_string: [ '/javascripts/route_string.js' ],
    route_regexp: [ '/javascripts/route_regexp.js' ],
    jquery: [ '/javascripts/jquery.js' ],
    jqueryui: [ '/javascripts/jquery.js', '/stylesheets/jqueryui.css', '/javascripts/jqueryui.js' ]
  }, "lib.libs({test: null}) has been deleted");
  
  equal(typeof lib.test, 'undefined', 'lib.test is undefined');
  
});

asyncTest('Load support_filetype', 3, function(){
  lib.support_filetype(function(){
    equal(lib.loaded()['/javascripts/support_filetype.js'], true, 'support_filetype.js loaded');
    equal(lib.loaded()['/stylesheets/support_filetype.css'], true, 'support_filetype.css loaded');
    equal(typeof unload, 'undefined', 'unload.js is not loaded');
    start();
  });
});

asyncTest('Load load_times', 3, function(){
  lib.load_times(function(){
    equal(lib.loaded()['/javascripts/load_times.js'], true, 'load_times.js loaded');
    equal(load_times, 1, 'load_times is 1');
    lib.load_times(function(){
      equal(load_times, 1, 'load_times is 1 too');
      start();
    });
  });
});


module('support_filetype');

asyncTest('stylesheet', 4, function() {
  lib.support_filetype(function(){
    equal($('.css').css('color'), 'rgb(0, 0, 1)', 'css file loaded');
    equal($('.sass').css('color'), 'rgb(0, 0, 1)', 'sass file loaded');
    equal($('.scss').css('color'), 'rgb(0, 0, 1)', 'scss file loaded');
    equal($('.rb_css').css('color'), 'rgb(0, 0, 1)', 'rb_css file loaded');
    start();
  });
});

asyncTest('javascript', 3, function() {
  lib.support_filetype(function(){
    equal(js, true, 'js file loaded');
    equal(coffee, true, 'coffeescript file loaded');
    equal(rb_js, true, 'rb_js file loaded');
    start();
  });
});


module('lib.routes');

asyncTest('String route', 1, function(){
  location.hash = '#Test_StringRoute';
  
  setTimeout(function(){
    ok(route_string, 'String route is applied');
    start();
  }, 1000);
});

asyncTest('RegExp route', 1, function(){
  location.hash = '#Test_RegExpRoute';
  
  setTimeout(function(){
    ok(route_regexp, 'RegExp route is applied');
    start();
  }, 1000);
});
