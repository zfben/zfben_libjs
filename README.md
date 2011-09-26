# Lib.js

Lib.js = Frontend build tool + lazyload js tool

## Getting Started

```bash
  gem install zfben_libjs
  
  libjs new < project_name >
```

## Feature:

* lazyload css and js files (base on LazyLoad.js)

* support css, js and images files

* support sass, scss, compass and coffeescript files

* support local files and remote files

* support custom ruby script

* support minify css and js files (base on sass and uglifier)

* support before and after events

## Support Filetype:

* .css    -   stylesheet

* .js     -   javascript

* .sass   -   sass

* .scss   -   scss

* .coffee -   coffeescript

* .rb     -   ruby

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
## Sinatra
```ruby
  helpers Zfben_libjs::Helpers
```