
fs = require "fs"
path = require "path"
File = require "./file"
util = require "util"
gaze = require "gaze"
async = require "async"

#sorter class
module.exports = class Group

  constructor: (@argv, @config) ->
    @watching = false

  run: ->
    @scan()
    # setInterval @scan.bind(@), 5*1000 if @argv.w
    @watch() if @argv.w

  scan: ->
    @files = []
    @dirsScanned = 0
    @dirsFound = 0
    @scanDir @argv.directory, @argv.r

  scanDir: (dir, depth) ->
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
          file = new File p, @
          @files.push file if file.valid

      if @dirsFound is ++@dirsScanned
        @sortFiles()

  sortFiles: ->
    extra = if @argv.r > 1 then " in #{@dirsScanned} directories" else ""
    console.log "Found #{@files.length} video files#{extra}.".grey
    if @files.length > 0
      console.log "Sorting now...".yellow
    async.parallel @files.map (f) -> f.run.bind f
    return

  watch: ->
    #only watch once
    return if @watching
    @watching = true

    processed = {}

    gazeQuery = "**/*.*" #.{#{@config.fileExtensions.join ','}}
    console.log "Watching '#{@argv.directory}/#{gazeQuery}' for changes...".grey

    gaze gazeQuery, cwd: path.join(@argv.directory,'..'), (err, watcher) =>
      if err
        console.log "Failed to watch: #{err}".red
        return
      watcher.on "all", (type, srcPath) =>
        return if processed[srcPath]
        processed[srcPath] = true

        console.log "WATCH EVENT: #{type} #{srcPath}".yellow if @argv.debug
        return if type not in ["renamed","added"]
        srcDir = path.dirname srcPath
        relaDir = path.relative(srcDir, @argv.directory) + path.sep
        #check file depth with path
        relaMatch = new RegExp "\.\.\\#{path.sep}{#{@argv.r-1},}"
        console.log "RELA MATCH #{relaMatch} DIR #{relaDir} ".cyan if @argv.debug
        return if relaMatch.test relaDir
        unless fs.existsSync srcPath
          console.log "WATCH FILE NOT FOUND #{srcPath}".yellow if @argv.debug
          return
        f = new File srcPath, @
        unless f.valid
          return console.log "WATCH FILE NOT VALID #{srcPath}".yellow if @argv.debug
        #wait 3 seconds
        setTimeout ->
          f.run()
        , 3*1000
