# save libs to `libs`
libs = {}

# save loaded source to `loaded`
loaded = {}

for link in document.getElementsByTagName('link')
  if link.href && link.href isnt ''
    loaded[link.href] = true

for script in document.getElementsByTagName('script')
  if script.src && script.src isnt ''
    loaded[script.src] = true

# pending
pending_urls = {}
pending_funcs = {}

# function for run funcs
run_funcs = ->
  loaded_string = [' ']
  for url of loaded
    loaded_string.push(url)
  loaded_string = loaded_string.join(' ') + ' '
  for urls, funcs of pending_funcs
    url_list = urls.split(' ')
    urls_loaded = true
    for url in url_list
      if loaded_string.indexOf(' ' + url + ' ') < 0
        urls_loaded = false
        break
    if urls_loaded
      for func in funcs
        func()
      delete(pending_funcs[urls])
  return true

# lib start here
lib = ->
  
  # progress arguments to each type
  css = []
  js = []
  funcs = []
  
  source_types = (args)->
    for arg in args
      switch typeof arg
        when 'string'
          if arg.indexOf(' ') >= 0
            source_types(arg.split(' '))
          else
            if typeof libs[arg] isnt 'undefined'
              source_types(libs[arg])
            else
              if /\.css[^\.]*$/.test(arg)
                css.push(arg)
              if /\.js[^\.]*$/.test(arg)
                js.push(arg)
        when 'function'
          funcs.push(arg)
        else
          if typeof arg.length isnt 'undefined' then source_types(arg)
    return true
  
  source_types(arguments)
  
  urls = css.concat(js)
  
  # progress css
  pending_css = []
  
  for url in css
    if typeof loaded[url] is 'undefined' && typeof pending_urls[url] is 'undefined'
      pending_urls[url] = true
      pending_css.push url
  
  if pending_css.length > 0
    loading_css = []
    if lib.defaults.version
      for url in pending_css
        loading_css.push url + lib.defaults.version
    else
      loading_css = pending_css
    LazyLoad.css(loading_css, ->
      for url in pending_css
        delete pending_urls[url]
        loaded[url] = true
      run_funcs()
    )
  
  # progress js
  pending_js = []
  
  for url in js
    if typeof loaded[url] is 'undefined' && typeof pending_urls[url] is 'undefined'
      pending_urls[url] = true
      pending_js.push url
  
  if js.length > 0
    loading_js = []
    if lib.defaults.version
      for url in pending_js
        loading_js.push url + lib.defaults.version
    else
      loading_js = pending_js
    LazyLoad.js(loading_js, ->
      for url in pending_js
        delete pending_urls[url]
        loaded[url] = true
      run_funcs()
    )
  
  # put funcs to pending_funcs
  if funcs.length > 0
    pending_funcs[urls.join(' ')] = funcs
    run_funcs()
  
  return {
    css: css
    js: js
    funcs: funcs
  }

# control loaded api
lib.loaded = ->
  args = Array.prototype.slice.call(arguments)
  switch args.shift()
    when 'add'
      for arg in args
        if typeof loaded[arg] is 'undefined'
          if typeof libs[arg] isnt 'undefined'
            for url in libs[arg]
              loaded[url] = true
          else
            loaded[arg] = true
      run_funcs()
    when 'del'
      for arg in args
        if typeof loaded[arg] isnt 'undefined'
          delete(loaded[arg])
        else
          if typeof libs[arg] isnt 'undefined'
            for url in libs[arg]
              delete(loaded[url])
  return loaded

# change libs api
lib.libs = (new_libs)->
  for lib_name, urls of new_libs
    delete(libs[lib_name])
    delete(lib[lib_name])
    if urls isnt null
      libs[lib_name] = urls
      ((lib_name) ->
        lib[lib_name] = ->
          args = [lib_name].concat(Array.prototype.slice.call(arguments))
          lib.apply(this, args)
      )(lib_name)
  return libs

lib.defaults = {}

window.lib = lib
