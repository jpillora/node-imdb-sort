

_ = require "lodash"
fs = require "fs"
path = require "path"
prompt = require "prompt"

#allowed template keys
keys = ['Title','Year','Rated','Released','Runtime','Genre','Director','Writer',
        'Actors','Plot','Poster','imdbRating','imdbVotes','imdbID','Type','Season','Episode']

#config schema
defaultSchema =
  replaceExisting:
    message: "Replace existing files"
    default: false
  tvshows:
    fileName:
      message: "File name format for your TV show episodes"
      default: "{{ Title }} - Season {{ Season }} Episode {{ Episode }}"
    root:
      message: "The root directory for your TV shows"
      default: "./TV Shows/"
    directoryPerShow:
      message: "Do you want a directory per TV show"
      default: true
    showName:
      message: "Folder name format for your TV show titles"
      default: "{{ Title }}"
    directoryPerSeason:
      message: "Do you want a directory per TV show season"
      default: false
    seasonName:
      message: "Folder name format for your TV show seasons"
      default: "Season {{ Season }}"
  movies:
    fileName:
      message: "Filename format for your movies"
      default: "{{ Title }} ({{ Year }})"
    root:
      message: "The root directory for your movies"
      default: "./Movies/"

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
      if _.isPlainObject(a) and a.message and _.isString(b)
        a.default = b
      return a

  #flatten schema for prompt
  schemafy: (obj) ->
    flat = {}
    visit = (o, parent = '') ->
      for k,v of o
        throw 'Dot in key!' if /\./.test k
        if _.isPlainObject(v) and not v.message and not v.default
          visit v, k
        else
          flat[(if parent then parent+"." else '')+k] = v
    visit obj
    return {properties:flat}

  schema: (defaults = {}) ->
    @schemafy @merge _.cloneDeep(defaultSchema), defaults

  objectify: (flat) ->
    obj = {}
    extract = (f, prefix = '') ->
      for k,v of f
        continue unless k.indexOf(prefix) is 0
        if m = k.match /(\w+)\./
          obj[k] = extract v, m[1]
        else
          obj[k] = v

    extract flat
    return obj

  gen: ->
    prompt.get @schema(@config), (err, result) ->
      console.log err or result
      process.exit(1)

    # get user input to first fill config
    #       mac     pc
    # HOME/Movies|Videos/Movies|TV Shows

  write: ->
    #write @config to @path

  read: ->
    contents = fs.readFileSync @path
    unless contents
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
