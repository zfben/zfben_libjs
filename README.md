# Lib.js

Lib.js = Frontend build tool + lazyload js tool

## Getting Started

```bash
  gem install zfben_libjs
  
  libjs new < project_name >
```

## Feature:

* lazyload css and js files (base on LazyLoad.js)
* minify css and js files (base on sass and uglifier)
* support sass, scss, compass and coffeescript files
* download remote files
* custom ruby script
* custom filetype
* before and after events
* custom routes

## Support Filetype:

* .css    -   stylesheet

* .js     -   javascript

* .sass   -   sass

* .scss   -   scss

* .coffee -   coffeescript

* .rb     -   ruby

* .???    -   custom filetype

## Javascript Example
```javascript
  // load jquery
  lib.jquery(function(){
    // something use jquery to do
  });
  
  // load jqueryui and not duplicate load jquery
  lib.jqueryui(function(){
    // something use jqueryui to do
  });
  
  // and you can load like
  lib('jquery', function(){
    // use jquery to do sth.
  });
  
  lib('jquery underscore', function(){
    // use jquery and underscore to do sth.
  });
```
## Rails Example
```ruby
  # Gemfile
  gem 'zfben_libjs'
```
```erb
  # layout.html.erb

  <%= lib %>
  # => <script src="/javascripts/lib.js?12345678"></script>
  
  <%= lib :home %>
  # => <script src="/javascripts/lib.js?12345678"></script><script>lib('home')</script>

  <%= lib 'home.css' %>
  # => <link rel="stylesheet" href="/stylesheets/home.css?12345678" /><script src="/javascripts/lib.js?12345678"></script>

  <%= lib 'home.js' %>
  # => <script src="/javascripts/home.js?12345678"></script><script src="/javascripts/lib.js?12345678"></script>
```
## Sinatra Example
```ruby
  helpers Zfben_libjs::Helpers
```

## Custom Filetype Example
```yaml
# add support_source to config yaml file
support_source:
  - mustache.rb
```
```ruby
# mustache.rb
class Zfben_libjs::Mustache < Zfben_libjs::Source
  def after_initialize
    @source = "this['#{File.basename(@filepath, '.mustache')}']=(data)->Mustache.to_html('''#{@source}''', data)"
  end
  
  def compile
    Zfben_libjs::Coffee.new(:source => @source).compile
  end
  
  def to_js
    compile
  end
  
  def minify
    @minified = Zfben_libjs::Js.new(:source => @source).minify
  end
end
```

## Routes
```yaml
# add routes to config yaml file
routes:
  "#Test_StringRoute": route_string
  "/#Test_RegExpRoute/": route_regexp
```

## More Settings

See https://github.com/benz303/zfben_libjs/blob/master/test.yml

## TODO

### libjs
* Make lib() return as defferred object
* Add ready event

### Compile
* Support Zfben_libjs::Libjs.new.build!(url)
* Support auto-compile when file changed
* Auto merge sass and scss to speed up compile
* Lazyload files to speed up load
* Add debug mode for javascript
* * use console.log(filepath)

### Web Service
* Use sinatra as web server
* UI for control compile