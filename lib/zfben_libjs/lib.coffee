# save loaded source to `loaded`
loaded = {}

# save libs to `libs`
libs = {}

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
    if js.length is 0 && funcs.length > 0
      LazyLoad.css(css, ->
        for url in css
          loaded[url] = true
        for func in funcs
          func()
      )
    else
      LazyLoad.css(css, ->
        for url in css
          loaded[url] = true
      )
  
  # progress js
  if js.length > 0
    if funcs.length > 0
      LazyLoad.js(js, ->
        for url in js
          loaded[url] = true
        for func in funcs
          func()
      )
    else
      LazyLoad.js(js, ->
        for url in js
          loaded[url] = true
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
