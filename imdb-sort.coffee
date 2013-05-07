
fs = require "fs"
http = require "http"
require "colors"
imdb = require "imdb-api"
google = require "google"
google.resultsPerPage = 1

exts = [
  "mp4"
  "m4v"
  "mkv"
  "avi"
]

home = process.env.HOME or process.env.HOMEPATH or process.env.USERPROFILE
dir = "#{home}/Movies/"

fs.readdir dir, (err, files) ->
  throw err if err
  files.forEach (f) -> new SortRun f

#sorter class
class SortRun

  constructor: (@file) ->
    @orig = @file
    @path = dir + @file
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

  # stat: ->
  #   #check file size
  #   fs.stat @path, (err, stats) =>
  #     throw "#{@path} #{err}" if err
  #     threshold = if @data.quality is '1080'
  #       11e8
  #     else if @data.quality is '720'
  #       9e8
  #     else
  #       7e8
  #     @preference = if stats.size > threshold then 'movie' else 'series'
  #     @search()

  search: ->

    #series if has season and episode
    @preference = if @data.season and @data.episode then 'series' else 'movie'

    console.log "Searching for '#{@data.title}'... (guess: #{@preference})".grey

    google "imdb #{@data.title} #{@preference}", (err, next, links) =>
      throw err if err
      console.log "Results for '#{@orig}'".green
      l = links[0].link
      m = l.match /^http:\/\/www\.imdb\.com\/.*\/tt(\d+)\//
      return unless m
      console.log "#{m[1]}".blue
      @retrieve m[1]

  # search: ->
  #   console.log "Searching for '#{@data.title}'... (guess: #{@preference})".grey
  #   imdb @data.title, (err, result) =>

  #     console.log "Results for '#{@orig}'".green
  #     return console.log "#{err.e.toString()} with code:\n#{err.str}".red if err
  #     return console.log "#{result.Error}".red if result.Error

  #     type = typeof result.Search
  #     return console.log "Invalid type:", result if type isnt 'object'

  #     console.log "Found #{result.Search.length} results. Matching...".green
  #     @match r for r in result.Search if result.Search

  retrieve: (id) ->
    console.log "Retrieving ID '#{id}'... (for: #{@data.title})".grey
    imdb.getById id, (err, data) =>
      console.log "Result for '#{@data.title}'\n#{JSON.stringify data,null,2}".blue

  match: (r) ->
    # console.log "'#{@data.title}' (#{@data.year}) vs '#{r.Title}' (#{r.Year})"
    return if @data.title.toLowerCase() isnt r.Title.toLowerCase()
    return if @data.year and @data.year isnt r.Year
    return if @found and @dist(@found.Year) < @dist(r.Year)
    @found = r
    console.log "Matched: #{r.Title} (#{r.Year}) - #{r.Type}".cyan

  dist: (y) ->
    Math.abs (new Date().getFullYear()) - parseInt(y)

#imdb lookup
# imdb = (query, callback) ->
#   # query = query.toLowerCase().replace ' ', '+'
#   # opts = {host: 'www.imdb.com', path: '/xml/find?json=1&nr=1&tt=on&q='+query}
#   query = query.toLowerCase().replace /\s/g, '%20'
#   opts = {host: 'www.omdbapi.com', path: '/?s='+query}

#   req = http.get opts, (res) ->
#     chunks = []
#     res.on 'data', (chunk) -> chunks.push chunk.toString()
#     res.on 'end', ->
#       try
#         str = chunks.join ''
#         data = JSON.parse str
#       catch e
#         callback {e,str}
#         return
#       callback null, data
#   req.on "error", (e) -> callback e



