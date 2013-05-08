
require "colors"
pathLib = require "path"
request = require "request"
google = require "google"
google.resultsPerPage = 1

exts = ["mp4","m4v","mkv","avi"]

#sorter class
module.exports = class SortFile

  constructor: (@path) ->
    console.log ">> #{@path}".yellow
    @orig = @file = pathLib.basename @path
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
    @search()

  extract: (caps, regex, ri = 0, rs = '') ->
    m = @file.match regex
    return unless m
    if caps
      for name, index of caps
        @data[name] = m[index]
    @file = @file.replace (if ri is 0 then regex else m[ri]), rs

  search: ->
    #series if has season and episode
    @preference = if @data.season and @data.episode then 'series' else 'movie'

    console.log "Searching for '#{@data.title}'... (guess: #{@preference})".grey

    return

    google "site:www.imdb.com #{@data.title} #{@preference}", (err, next, links) =>
      throw err if err
      console.log "Results for '#{@orig}'".green
      l = links[0].link
      m = l.match /^http:\/\/www\.imdb\.com\/.*\/(tt\d+)\//
      unless m
        console.log "Could not find '#{@data.title}' on IMDB".grey
        return

      console.log "#{m[1]}".blue
      @retrieve m[1]

  retrieve: (id) ->
    console.log "Retrieving IMDB item '#{id}'... (#{@data.title})".grey
    request.get "http://www.omdbapi.com/?i=#{id}", (err, res) =>

      throw err if err
      try
        data = JSON.parse res.body
      catch e

      console.log "Result for '#{@data.title}'\n#{JSON.stringify data,null,2}".blue


      if typeof data.episodes isnt 'function'
        return @move()

      data.episodes (err, eps) =>
        console.log "Episodes for '#{@data.title}'\n#{JSON.stringify eps,null,2}".blue
        @move()

  move: (r) ->
    console.log "Moving #{@orig}...".grey




