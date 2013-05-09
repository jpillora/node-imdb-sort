
_ = require "lodash"
mkdirp = require "mkdirp"
fs = require "fs"
path = require "path"
SortSearch = require "./search"

exts = ["mp4","m4v","mkv","avi"]

#sorter class
module.exports = class SortFile

  constructor: (p, @group) ->
    @fullPath = p
    @config = @group.config
    @orig = @file = path.basename @fullPath
    @data = {}
    #extract important data, remove rubbish
    @extract {ext:1}, /\.(\w+)$/
    return unless @data.ext in exts
    @extract null, /[^A-Za-z0-9]/g, 0, ' '
    @extract null, /\b(hdtv|brrip|dvdrip|dvdscr|bluray|ac3|subs)\b/gi
    @extract {year:1}, /\b(19\d\d|20\d\d)\b/
    @extract {quality:1}, /(720|1080)p/
    @extract {encoding:0}, /(x264|divx|xvid)/i
    @extract {season:2,episode:4}, /(S|Season\s*)(\d+)\s*(E|Episode\s*)(\d+)/i
    unless @data.season and @data.episode
      @extract {season:1,episode:2}, /\b(\d{1})(\d{2})\b/
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

    @ready = true

  run: ->
    return unless @ready
    SortSearch.search @data.title, @preference, (err, result) =>
      throw err if err
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

    dir = typeConfig.root

    if tv
      @result.Season = @data.season
      @result.Episode = @data.episode

      if typeConfig.directoryPerShow
        dir = path.join dir, @template typeConfig.showName, @result

      if typeConfig.directoryPerSeason
        dir = path.join dir, @template typeConfig.seasonName, @result

    fileName = @template typeConfig.fileName, @result

    finalPath = "#{path.join(dir, fileName)}.#{@data.ext}"

    console.log """Moving: '#{@fullPath}' to
                   .       '#{finalPath}'""".green

    if not @config.replaceExisting and fs.existsSync finalPath
      return console.log "Will not overwrite: #{@fullPath}"

    #create missing dirs
    mkdirp.sync dir

    #dooo eeettttt
    fs.rename @fullPath, finalPath, (err) =>
      console.log "Error moving: #{@fullPath}".red if err


