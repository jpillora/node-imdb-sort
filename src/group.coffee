
fs = require "fs"
path = require "path"
SortFile = require "./file"

#sorter class
module.exports = class SortGroup

  constructor: (@argv, @config) ->
    @files = []
    @watching = false
    @filesSorted = 0

  run: ->
    @scanDir @argv.directory

  scanDir: (dir, depth = @argv.r) ->
    return if depth is 0
    dirfiles = fs.readdirSync dir
    throw "Read dir: #{dir} failed" unless dirfiles

    for f in dirfiles
      continue if /^\./.test f
      p = path.join dir,f
      stats = fs.statSync p
      throw "Stat file: #{p} failed" unless stats
      if stats.isDirectory()
        @scanDir p, depth-1
      else
        file = new SortFile p, @
        @files.push file if file.ready

    @sortFiles()

  sortFiles: ->
    console.log "Found #{@files.length} video files.".grey

    if @files.length is 0
      return @watch()

    console.log "Sorting now...".yellow
    for f in @files
      f.run => @filedSorted()

  filedSorted: ->
    @filesSorted++
    @watch()

  watch: ->
    # console.log @argv.w , @watching , @filesSorted , @files.length
    return if not @argv.w or @watching or @filesSorted isnt @files.length
    @watching = true

    console.log "Watching '#{@argv.directory}' for changes...".grey
    fs.watch @argv.directory, {persistant:true}, (event, p) =>
      return if event is 'change'
      return unless fs.existsSync p
      f = new SortFile p, @
      f.run() if f.ready

      

