
_ = require "lodash"
fs = require "fs"
path = require "path"
mkdirp = require "mkdirp"
strip = require("colors").stripColors
prompt = require "prompt"
prompt.message = "imdb-sort".yellow
prompt.colors = false

#allowed template keys
keys = ['Title','Year','Rated','Released','Runtime','Genre','Director','Writer',
        'Actors','Plot','Poster','imdbRating','imdbVotes','imdbID','Type','Season','Episode']

videoDirName = if fs.existsSync(path.join(home,'Movies')) then 'Movies' else 'Videos'
defaultVideoDir = path.join home, videoDirName

validators =
  bool:
    conform: (str) -> /^(true|false)$/.test strip str
    message: "Must be 'true' or 'false'"
    before: (str) -> strip(str) is 'true'
  template:
    conform: (str) ->
      templates = str.match(/\{\{\s*(\w+)\s*\}\}/g) or []
      for t in templates
        k = t.match(/\{\{\s*(\w+)\s*\}\}/)[1]
        unless k and k in keys
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
  fileExtensions:
    description: "List organisable file types (comma separated)"
    default: "mp4,m4v,mkv,avi"
    before: (str) -> strip(str).replace(/\s/g,'').split ','
  tvshows:
    root:
      description: "The root directory for your TV shows"
      default: path.join defaultVideoDir, "TV Shows"
    fileName:
      description: "File name format for your TV show episodes"
      default: "{{ Title }} - Season {{ Season }} Episode {{ Episode }}"
      validator: 'template'
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
    root:
      description: "The root directory for your movies"
      default: path.join defaultVideoDir, "Movies"
    fileName:
      description: "Filename format for your movies"
      default: "{{ Title }} ({{ Year }})"
      validator: 'template'

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
      return a unless _.isPlainObject(a)
      return @merge(a,b) if _.isPlainObject(b)
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
          # v.description += "\nenter to use"
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
      Welcome to #{'IMDb Sort'.yellow}. Your default configuration file will now be generated and saved at this location:
        "#{@path.yellow}"
      Please follow the prompts below.
      To use an alternative configuration, use the -c option.

      Note:
        * Default values are in the brackets "( #{'...'.cyan} )"
        * Placeholder strings are denoted by the double curlys "{{ ... }}"
        * Paths starting with "~#{path.sep}" will get converted to "#{home}#{path.sep}"

    """

    prompt.start()
    prompt.get @schemafy(@config), (err, result) =>
      @config = @objectify result
      @write()

  write: ->
      
    configStr = JSON.stringify @config, null, 2
    
    mkdirp.sync path.dirname @path

    fs.writeFile @path, configStr, (err) =>
      return @done err if err
      @done null, @config

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
