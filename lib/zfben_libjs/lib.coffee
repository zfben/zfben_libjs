# save libs to `libs`
libs = {}

# save loaded source to `loaded`
loaded = {}

# save pending funcs in `pending_funcs`
pending_funcs = {}

# function for run funcs
run_funcs = ->
  loaded_string = ' ' + loaded.join(' ') + ' '
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
          if typeof loaded[arg] is 'undefined'
            if arg.indexOf(' ') >= 0
              source_types(arg.split(' '))
            else
              if typeof libs[arg] isnt 'undefined' then source_types(libs[arg])
              if /\.css[^\.]*$/.test(arg) then css.push(arg)
              if /\.js[^\.]*$/.test(arg) then js.push(arg)
        when 'function'
          funcs.push(arg)
        else
          if typeof arg.length isnt 'undefined' then source_types(arg)
    return true
  
  source_types(arguments)
  
  # progress css
  if css.length > 0
    LazyLoad.css(css, ->
      for url in css
        loaded[url] = true
      run_funcs()
    )
  
  # progress js
  if js.length > 0
    LazyLoad.js(js, ->
      for url in js
        loaded[url] = true
      run_funcs()
    )
  
  # if everything is loaded, run funcs
  if css.length is 0 && js.length is 0 && funcs.length > 0
    for func in funcs
      func()
  
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
          loaded[arg] = true
    when 'del'
      for arg in args
        if typeof loaded[arg] isnt 'undefined'
          delete(loaded[arg])
  return loaded

# change libs api
lib.libs = (new_libs)->
  for name, urls of new_libs
    if urls isnt null
      libs[name] = urls
      ((name, urls)->
        lib[name] = ->
          lib(urls, arguments)
      )(name, urls)
    else
      delete(libs[name])
      delete(lib[name])
  return libs

window.lib = lib
