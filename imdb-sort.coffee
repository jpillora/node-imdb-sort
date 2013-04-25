
fs = require "fs"
imdb = require "imdb-api"

normalize = (str) ->
  str.replace(/[^a-zA-Z0-9]/g, ' ')

check = (file) ->

  console.log "================="

  orig = file





  m = file.match /\.(\w+$)/
  if m
    ext = m[1]
    file = file.replace m[0], ''

  file = normalize file


  m = file.match /(720|1080)p/
  if m
    quality = m[0]
    file = file.replace m[0], ''

  m = file.match /(x264|divx|xvid)/i
  if m
    encoding = m[0]
    file = file.replace m[0], ''

  m = file.match /(S|Season\s*)(\d+)\s*(E|Episode\s*)(\d+)/i
  if m
    season = m[2]
    episode = m[4]
    file = file.replace m[0], ''
  
  if not m
    m = file.match /\b(\d{1})(\d{2})\b/
    if m
      season = m[1]
      episode = m[2]
      file = file.replace m[0], ''

  m = file.match /[a-zA-Z\ ]+((19|20)\d{2})?/g
  if m
    console.log orig
    console.log m
    console.log season, episode
    console.log ext
    console.log encoding
    console.log quality

query = process.argv[2];

search = (query) ->

  return unless query

  console.log("SEARCHING FOR", query);

  imdb.get query, (err, result) ->

      console.log("RESULTS FOR", query,'\n', result);

      return unless result?.episodes

      result.episodes (err, moreThings) ->
        console.log("EPISODES FOR", query,'\n', moreThings);

fs.readdir "/Volumes/jpillora/Movies", (err, files) ->
  throw err if err
  files.forEach (f) ->
    check f