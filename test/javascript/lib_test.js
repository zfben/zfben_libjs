module('lib init');

test('Exists files', 5, function(){
  equal(typeof lib, 'function', 'lib is a function');
  equal(typeof lib.loaded, 'function', 'lib.loaded is a function');
  deepEqual(lib.loaded(), {
    'http://code.jquery.com/jquery.min.js': true,
    'http://code.jquery.com/qunit/qunit-git.css': true,
    'http://code.jquery.com/qunit/qunit-git.js': true,
    'http://localhost:4711/callback.js': true,
    'http://localhost:4711/javascripts/lib.js': true
  }, 'Exists files are ok');
  equal(typeof lib.libs, 'function', 'lib.libs is a function');
  deepEqual(lib.libs(), {
    lazyload: ['/javascripts/lazyload.js'],
    support_filetype: [
      '/stylesheets/support_filetype.css',
      '/javascripts/support_filetype.js'
    ]
  }, 'lib.libs is ok');
});


module('support_filetype');

asyncTest('Load support_filetype', 2, function(){
  lib.support_filetype(function(){
    equal(lib.loaded()['/javascripts/support_filetype.js'], true, 'support_filetype.js loaded');
    equal(lib.loaded()['/stylesheets/support_filetype.css'], true, 'support_filetype.css loaded');
    start();
  });
});

asyncTest('stylesheet', 4, function() {
  lib.support_filetype(function(){
    equal($('.css').css('font-size'), '1px', 'css file loaded');
    equal($('.sass').css('font-size'), '2px', 'sass file loaded');
    equal($('.scss').css('font-size'), '3px', 'scss file loaded');
    equal($('.rb_css').css('font-size'), '4px', 'rb_css file loaded');
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
