p      = console.log
coffee = require 'coffee-script'
mime   = require 'mime'
http   = require 'http'
path   = require 'path'
fs     = require 'fs'
stylus = require 'stylus'

class CodeDirectory
  constructor: (directory) ->
    @root = new RootCodeFile
    @source = ''
    @files = []
    for file in fs.readdirSync(directory)
      if file[-7..-1] is '.coffee'
        f = new CodeFile("#{directory}/#{file}")
        @root.children.push f
        @files.push f
        @files[f.name] = f
    @files.forEach (a) =>
      @files.forEach (b) =>
        throw "Circular require invocation between '#{a.path}' and '#{b.path}'" if @requires(a, b) and @requires(b, a)
      a.reqs.forEach (req) =>
        @files[req].children.push a
    @import @root

  import: (file) ->
    @source += file.source + '\n\n'
    file.imported = true
    file.children.forEach (child) =>
      if not child.imported
        if not file.grandDescendant child
          @import child

  requires: (a, b) ->
    return true if a.requires(b)
    for name in a.reqs
      return true if @requires(@files[name], b)
    false

  compile: ->
    @output = coffee.compile @source, bare: true

  send: (res, name) ->
    @files.forEach (file) ->
      try
        file.compile()
      catch error
        res.end "alert(\"(#{file.name}) #{error.message}\")"
        p error.stack
        return
    try
      @compile()
    catch error
      res.end "alert(\"#{error.message}\")"
      p error.stack
      return
    res.end @output

class CodeFile
  constructor: (filepath = null) ->
    @path     = filepath
    @name     = ''
    @source   = ''
    @children = []
    @reqs     = []
    @imported = false
    if @path
      @name = path.basename @path, '.coffee'
      @source = fs.readFileSync(@path).toString('utf-8')
      if @source[0..1] == '#!'
        n = @source.split(/\n|\r/)[0].split(/\s*,\s*/)
        m = n[0].split(/\s+/)
        command = m[1]
        args = [m[2]].concat n[1..-1]
        switch command
          when 'require'
            @reqs = args

  requires: (other) ->
    other.name in @reqs

  compile: ->
    @output = coffee.compile @source

  descendant: (file) ->
    for child in @children
      return true if child == file or child.descendant(file)
    false

  grandDescendant: (file) ->
    for child in @children
      return true if child.descendant(file)
    false

class RootCodeFile extends CodeFile
  constructor: ->
    super()
    @name = '__root__'


server = http.createServer (req, res) ->
  p "#{req.connection.remoteAddress} #{req.method} #{req.url}"
  filename = req.url[1..-1]
  filename = filename[0...(filename.indexOf('?'))] if filename.indexOf('?') >= 0
  filename = 'index.html' if filename == ''
  if filename == 'script.js'
    res.writeHead 200, { 'Content-Type' : 'application/javascript' }
    try
      directory = new CodeDirectory 'js'
      directory.send res
      fs.writeFileSync 'script.js', directory.output, 'utf-8'
    catch error
      res.end "alert(\"#{error}\")"
      p error.stack
  else
    if path.existsSync filename
      data = fs.readFileSync filename
      res.writeHead 200, { 'Content-Type' : mime.lookup filename }
      res.end data
    else
      res.writeHead 404
      res.end 'File not found\n'

server.listen 1337, '0.0.0.0'
