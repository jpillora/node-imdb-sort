

_ = require "lodash"
fs = require "fs"
path = require "path"
strip = require("colors").stripColors
prompt = require "prompt"
prompt.message = "imdb-sort"
prompt.colors = false

#allowed template keys
keys = ['Title','Year','Rated','Released','Runtime','Genre','Director','Writer',
        'Actors','Plot','Poster','imdbRating','imdbVotes','imdbID','Type','Season','Episode']

videoDir = if path.existsSync(path.join(home,'Videos')) then 'Videos' else 'Movies'

validators =
  bool:
    conform: (str) -> /^(true|false)$/.test strip str
    message: "Must be 'true' or 'false'"
    before: (str) -> strip(str) is 'true'
  template:
    conform: (str) ->
      for t in str.match(/\{\{\s*(\w+)\s*\}\}/g)
        k = t.match(/\{\{\s*(\w+)\s*\}\}/)[1]
        unless k in keys
          console.log "error:".red + "   Contains invalid template key: '#{k.red}'\n  It can be one of [#{keys}]"
          return false
      true
    message: ""

#config schema
defaultSchema =
  replaceExisting:
    description: "Replace existing files"
    default: false
    validator: 'bool'
  tvshows:
    fileName:
      description: "File name format for your TV show episodes"
      default: "{{ Title }} - Season {{ Season }} Episode {{ Episode }}"
      validator: 'template'
    root:
      description: "The root directory for your TV shows"
      default: "~/#{videoDir}/TV Shows/"
    directoryPerShow:
      description: "Create a directory per TV show"
      default: true
      validator: 'bool'
    showName:
      description: "Folder name format for your TV show titles"
      default: "{{ Title }}"
      validator: 'template'
    directoryPerSeason:
      description: "Create a directory per TV show season"
      default: false
      validator: 'bool'
    seasonName:
      description: "Folder name format for your TV show seasons"
      default: "Season {{ Season }}"
  movies:
    fileName:
      description: "Filename format for your movies"
      default: "{{ Title }} ({{ Year }})"
      validator: 'template'
    root:
      description: "The root directory for your movies"
      default: "~/#{videoDir}/Movies/"

#
module.exports =
  load: (@argv, @done) ->
    @path = @argv.config

    if fs.existsSync @path
      @read()
    else
      console.log "Creating config '#{@path}'".grey
      @gen()

  #custom merge - merges a config into the schema
  merge: (x,y) ->
    _.merge x, y, (a,b) =>
      if _.isPlainObject(a) and _.isPlainObject(b)
        return @merge(a,b)
      if _.isPlainObject(a) and a.description and _.isString(b)
        a.default = b
      return a

  #flatten schema for prompt
  schemafy: (config = {}) ->
    obj = @merge _.cloneDeep(defaultSchema), config
    flat = {}
    visit = (o, parent = '') ->
      for k,v of o
        throw 'Dot in config key!' if /\./.test k
        if _.isPlainObject(v) and not v.description and not v.default
          visit v, k
        else

          if v.validator and (vObj = validators[v.validator])
            delete v.validator
            _.extend v, vObj

          if v.default isnt `undefined`
            v.default = "#{v.default}".cyan

          key = (if parent then parent+"." else '')+k
          flat[key] = v
    visit obj
    return {properties:flat}

  objectify: (flat) ->
    obj = {}
    re = /^(\w+)\./
    for k,v of flat
      p = obj
      while(m = k.match re)
        kk = m[1]
        unless p[kk]
          p[kk] = {}
        p = p[kk]
        k = k.replace re, ''
      v = strip(v) if typeof v is 'string'
      p[k] = v
    return obj

  gen: ->

    console.log """
      Welcome to #{'IMDb'.yellow} Sort. A configuration file could not be found, please take a minute to create one now.
      It will be created here:
        "#{@path}"
        You can change this with the -c option

      Note:
        * Default values are in the brackets "( ... )"
        * Template strings are inside the double curlys "{{ ... }}"
        * Paths starting with "~/" will get converted to "#{home}/"

    """

    prompt.start()
    prompt.get @schemafy(@config), (err, result) =>

      @config = @objectify result

      console.log err or @config
      process.exit(1)

    # get user input to first fill config
    #       mac     pc
    # HOME/Movies|Videos/Movies|TV Shows

  write: ->
    #write @config to @path

  read: ->
    fs.readFile @path, (err, contents) =>
      if err or not contents
        return @done "Cannot read: #{@path}"

      try
        @config = JSON.parse contents
      catch e
        return @done e

      #ready
      if @argv.setup
        console.log "Editing config '#{@path}'".grey
        @gen @config
      else
        console.log "Using config '#{@path}'".grey
        @done null, @config
