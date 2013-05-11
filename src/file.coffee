
_ = require "lodash"
mkdirp = require "mkdirp"
fs = require "fs"
path = require "path"
SortSearch = require "./search"


#sorter class
module.exports = class SortFile

  constructor: (p, @group) ->
    # console.log "NEW FILE #{p}".yellow
    @fullPath = p
    @config = @group.config
    @orig = @file = path.basename @fullPath
    @data = {}
    #extract important data, remove rubbish
    @extract {ext:1}, /\.(\w+)$/
    return unless @data.ext in @config.fileExtensions
    @extract null, /\ -/g
    @extract null, /[^A-Za-z0-9]/g, 0, ' '
    @extract null, /\b(hdtv|brrip|dvdrip|dvdscr|bluray|ac3|subs)\b/gi
    @extract {title:1,year:2}, /(.*)\b(19\d\d|20\d\d)\b/
    @extract {quality:1}, /(720|1080)p/
    @extract {encoding:1}, /(x264|divx|xvid)/i
    @extract {title:1,season:3,episode:5}, /(.*)\b(S|Season)[\.-]?\s*(\d+)\s*(E|Episode)[\.-]?\s*(\d+)/i
    unless @data.season and @data.episode
      @extract {title:1,season:2,episode:3}, /(.*)\b(\d{1})(\d{2})\b/
    unless @data.title
      @extract {title:0}, /([A-Za-z0-9]+\ ?)+[A-Za-z0-9]+/
    #start search
    @found = null
    #series if has season and episode
    if @data.season and @data.episode
      @preference = 'series'
      @data.season = parseInt @data.season, 10
      @data.episode = parseInt @data.episode, 10
    else
      @preference = 'movie'

    @data.title = @data.title.replace /(^\s+|\s+$)/g,''
    @ready = true

  run: (@done) ->
    return unless @ready
    SortSearch.search @data.title, @preference, (err, result) =>
      throw err if err or not result
      @result = _.clone result
      @move()

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
    mov = @result.Type is 'movie'
    tv = @result.Type is 'series'

    unless mov or tv
      return console.log "Unknown type: #{@result.Type}".red

    typeConfig = @config[if mov then 'movies' else 'tvshows']

    dir = path.resolve typeConfig.root.replace /^~/, home

    if tv
      @result.Season = @data.season
      @result.Episode = @data.episode

      if typeConfig.directoryPerShow
        dir = path.join dir, @template typeConfig.showName, @result

      if typeConfig.directoryPerSeason
        dir = path.join dir, @template typeConfig.seasonName, @result

    fileName = @template typeConfig.fileName, @result

    @finalPath = "#{path.join(dir, fileName)}.#{@data.ext}"

    if not @config.replaceExisting and fs.existsSync @finalPath
      return console.log "Will not overwrite: #{@fullPath}"

    if @group.argv.preview
      return @success(true)

    #create missing dirs
    mkdirp.sync dir

    #dooo eeettttt
    fs.rename @fullPath, @finalPath, (err) =>
      return console.log "Error moving: #{@fullPath}".red if err
      @success()

  cleanPath: (full) ->
    rela = path.relative pwd, full
    (if /^(..\/){2,}/.test(rela) then full else "./#{rela}").green

  success: (preview) ->
    console.log "#{if preview then 'Preview ' else ''}Move:\n  " +
      @cleanPath(@fullPath.toString()) + " to \n  " +
      @cleanPath(@finalPath.toString())

    @done() if @done



