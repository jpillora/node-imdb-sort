
fs = require "fs"
path = require "path"
SortFile = require "./file"
util = require "util"
watch = require "watch"

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
      return @sortComplete()

    console.log "Sorting now...".yellow

    #async, 5 concurrent
    for f in @files
      f.run (err) => @fileComplete err, f

  fileComplete: (err, f) ->
    @filesSorted++
    @sortComplete()

  sortComplete: ->
    #show report
    @watch()

  watch: ->
    # console.log @argv.w , @watching , @filesSorted , @files.length
    return if not @argv.w or @watching or @filesSorted isnt @files.length
    @watching = true

    processed = {}

    console.log "Watching '#{@argv.directory}' for changes...".grey

    watch.createMonitor @argv.directory, (monitor) =>
      monitor.on "created", (srcPath, stat) =>
        return if processed[srcPath]
        processed[srcPath] = true

        srcDir = path.dirname srcPath
        relaDir = path.relative(srcDir, @argv.directory) + path.sep
        relaMatch = new RegExp "\.\.\\#{path.sep}{#{@argv.r-1},}"

        # console.log "RELA MATCH #{relaMatch} (#{tooDeep}) DIR #{relaDir} ".cyan
        return if relaMatch.test relaDir

        console.log "WATCH EVENT #{stat}, #{srcPath}".yellow if @argv.debug
        # return if event is 'change'
        # srcPath = path.join @argv.directory, p
        unless fs.existsSync srcPath
          console.log "WATCH FILE NOT FOUND #{srcPath}".yellow if @argv.debug
          return
        f = new SortFile srcPath, @
        return unless f.ready
        f.run (err) => @fileComplete err, f



