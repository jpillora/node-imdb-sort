
_ = require "lodash"
strip = require("colors").stripColors
mkdirp = require "mkdirp"
fs = require "fs"
path = require "path"
Search = require "./search"


dirNameBlacklist = ['?','%','*',':','|','"','<','>','.']
fileNameBlacklist = dirNameBlacklist.concat ['/','\'']
makeBlacklistRegex = (arr) ->
  new RegExp "[#{arr.map((s)->"\\#{s}").join('')}]","g"

dirNameRegex = makeBlacklistRegex dirNameBlacklist
fileNameRegex = makeBlacklistRegex fileNameBlacklist

#sorter class
module.exports = class File

  constructor: (p, @group) ->
    @srcPath = p
    { @config, @argv } = @group
    console.log "NEW FILE #{p}".yellow if @argv.debug
    @orig = @file = path.basename @srcPath
    @data = {}
    #extract important data, remove rubbish
    @extract {ext:1}, /\.(\w+)$/
    return unless @data.ext in @config.fileExtensions
    return if @argv.f and not @argv.f.test @srcPath
    return if @argv.i and @argv.i.test @srcPath
    @extract null, /\ -/g
    @extract null, /[^A-Za-z0-9]/g, 0, ' '
    @extract null, /\b(hdtv|brrip|dvdrip|dvdscr|bluray|ac3|subs)\b/gi
    @extract {title:1,year:2}, /(.*)\b(19\d\d|20\d\d)\b/
    @extract {quality:1}, /(720|1080)p/
    @extract {encoding:1}, /(x264|divx|xvid)/i
    @extract {title:1,season:3,episode:5}, /(.*)\b(S|Season)[\.-]?\s*(\d+)\s*.{0,3}\s*(E|Episode)[\.-]?\s*(\d+)/i
    unless @data.season and @data.episode
      @extract {title:1,season:2,episode:3}, /(.*)\b(\d{1,2}).?(\d{2})\b/
    unless @data.title
      @extract {title:0}, /([A-Za-z0-9]+\ ?)+[A-Za-z0-9]+/
    #series if has season and episode
    if @data.season and @data.episode
      @preference = 'series'
      @data.season = parseInt @data.season, 10
      @data.episode = parseInt @data.episode, 10
    else
      @preference = 'movie'

    @data.title = @data.title.replace /(^\s+|\s+$)/g,''
    @valid = true

  run: (@done = ->) ->
    return unless @valid

    if @argv.debug
      console.log "RUN FILE: #{@srcPath}\n with data: #{JSON.stringify @data, null, 2}\n".yellow

    Search.search @data.title, @data.year, @preference, (err, result) =>
      if err
        console.log "Search error: #{err}".red
        @done()
        return
      @result = _.clone result
      @move()
    return

  extract: (caps, regex, ri = 0, rs = '') ->
    m = @file.match regex
    return unless m
    if caps
      for name, index of caps
        @data[name] = m[index]
    @file = @file.replace (if ri is 0 then regex else m[ri]), rs

  template: (str, obj) ->
    str.replace /{{\s*(\w+)\s*}}/g, (s,key) -> obj[key]

  move: ->
    mov = @preference is 'movie'

    typeConfig = @config[if mov then 'movies' else 'tvShows']

    dir = path.resolve typeConfig.root.replace /^~/, home

    if not mov
      @result.Season =  (if @data.season  < 10 then "0" else "") + @data.season
      @result.Episode = (if @data.episode < 10 then "0" else "") + @data.episode

      if typeConfig.directoryPerShow
        dirName = @template typeConfig.showName, @result
        dirName = dirName.replace dirNameRegex, ''
        dir = path.join dir, dirName

      if typeConfig.directoryPerSeason
        dirName = @template typeConfig.seasonName, @result
        dirName = dirName.replace dirNameRegex, ''
        dir = path.join dir, dirName

    fileName = @template typeConfig.fileName, @result
    fileName = fileName.replace fileNameRegex, ''

    @destPath = "#{path.join(dir, fileName)}.#{@data.ext}"

    if @argv.preview
      @success("PREIVEW. Did not move")
      @handleSubs()
      return

    if not @config.replaceExisting and fs.existsSync @destPath
      @success("SKIPPED. File exists at destination. Cancelled move")
      return

    #create missing dirs
    mkdirp dir, =>
      #dooo eeettttt
      fs.rename @srcPath, @destPath, (err) =>
        return console.log "Error moving: #{err}".red if err
        @success("Successfull moved")
        @handleSubs()

  handleSubs: ->
    #handle subtitle file
    subsSrc = strip @subtitlePath(@srcPath)
    subsDest = strip @subtitlePath(@destPath)

    return unless subsSrc and fs.existsSync subsSrc
    return @displayMessage subsSrc, subsDest, "PREIVEW. Did not move (subs)" if @argv.preview

    fs.rename subsSrc, subsDest, (err) =>
      return console.log "Error moving: #{err}".red if err
      @displayMessage(subsSrc, subsDest, "Successfull moved")

  subtitlePath: (full) ->
    full.replace new RegExp("\\.#{@data.ext}$"),".srt"

  cleanPath: (full) ->
    rela = path.relative pwd, full.toString()
    (if new RegExp("(\\.\\.\\#{path.sep}){2,}").test(rela) then full else ".#{path.sep}#{rela}").green

  displayMessage: (src, dest, str) ->
    console.log "#{str}:\n  #{@cleanPath src} to \n  #{@cleanPath dest}"

  success: (str) ->
    @displayMessage @srcPath, @destPath, str
    @done()



