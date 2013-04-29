
fs = require "fs"
http = require "http"
require "colors"

exts = [
  "mp4"
  "m4v"
  "mkv"
  "avi"
]

home = process.env.HOME or process.env.HOMEPATH or process.env.USERPROFILE

class SortRun

  constructor: (@file) ->
    @orig = @file
    @data = {}
    @extract {ext:1}, /\.(\w+)$/
    return unless @data.ext in exts
    @extract null, /[^A-Za-z0-9]/g, 0, ' '
    @extract null, /(hdtv|brrip|dvdrip|dvdscr)/gi
    @extract {year:1}, /(19\d\d|20\d\d)/
    @extract {quality:1}, /(720|1080)p/
    @extract {encoding:0}, /(x264|divx|xvid)/i
    @extract {season:2,episode:4}, /(S|Season\s*)(\d+)\s*(E|Episode\s*)(\d+)/i
    unless @season and @episode
      @extract {season:1,episode:2}, /\b(\d{1})(\d{2})\b/

    @extract {title:0}, /([A-Za-z0-9]+\ ?)+[A-Za-z0-9]+/

    @search()

  extract: (caps, regex, ri = 0, rs = '') ->
    m = @file.match regex
    return unless m
    if caps
      for name, index of caps
        @data[name] = m[index]
    @file = @file.replace (if ri is 0 then regex else m[ri]), rs

  search: ->
    console.log "Searching for '#{@data.title}'...".grey
    imdb @data.title, (err, result) =>

      console.log "Results for '#{@data.title}'".green
      return console.log((""+err).toString().red) if err

      keys = Object.keys result
      console.log "Keys: ".green, keys
      if result.Search
        console.log "Results: ".green, result.Search

      # if result.title_popular
      #   console.log "Popular: ".green, result.title_popular[0]
      # else if result.title_exact
      #   console.log "Exact: ".green, result.title_exact[0]
      # else if result.title_approx
      #   console.log "Approx: ".green, result.title_approx[0]

imdb = (query, callback) ->
  # query = query.toLowerCase().replace ' ', '+'
  # opts = {host: 'www.imdb.com', path: '/xml/find?json=1&nr=1&tt=on&q='+query}
  query = query.toLowerCase().replace ' ', '%20'
  opts = {host: 'www.omdbapi.com', path: '/?s='+query}

  req = http.get opts, (res) ->
    chunks = []
    res.on 'data', (chunk) -> chunks.push chunk.toString()
    res.on 'end', ->
      try
        data = JSON.parse chunks.join ''
      catch e
        callback e
        return
      callback null, data
  req.on "error", (e) -> callback e

fs.readdir "#{home}/Movies/Movies", (err, files) ->
  throw err if err
  files.forEach (f) -> new SortRun f


