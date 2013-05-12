
fs = require "fs"
path = require "path"
SortFile = require "./file"

#sorter class
module.exports = class SortGroup

  constructor: (@argv, @config) ->
    @files = []
    @watching = false
    @filesSorted = 0
    @dirsFound = 0
    @dirsScanned = 0

  run: ->
    @scanDir @argv.directory

  scanDir: (dir, depth = @argv.r) ->
    return if depth is 0

    @dirsFound++
    fs.readdir dir, (err, dirfiles) =>
      unless dirfiles
        console.log "Read dir failed on '#{dir}'".red
        @dirsFound--
        return

      console.log "Scanning #{dirfiles.length} files in '#{dir}'...".grey

      for f in dirfiles
        continue if /^\./.test f
        p = path.join dir,f
        stats = fs.statSync p
        unless stats
          console.log "Stat failed on file '#{p}'".red
          continue
        if stats.isDirectory()
          @scanDir p, depth-1
        else
          file = new SortFile p, @
          @files.push file if file.ready

      if @dirsFound is ++@dirsScanned
        @sortFiles()

  sortFiles: ->

    extra = if @argv.r > 1 then " in #{@dirsScanned} directories" else ""

    console.log "Found #{@files.length} video files#{extra}.".grey

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
      console.log "WATCH EVENT #{event}, #{p}".yellow
      return if event is 'change'
      return unless fs.existsSync p
      f = new SortFile p, @
      f.run() if f.ready



