
http = require "http"
request = (url, done) ->
  throw "Invalid URL" unless (m = url.match /^http:\/\/([^\/]+)(.*)/)
  http.request({ host:m[1], path:m[2] }, (res) ->
    str = ''
    res.on 'data', (c) -> str += c
    res.on 'end', -> res.body = str; done res
  ).end()

#https://logs-01.loggly.com/inputs/35bbdd2e-20e9-4537-b401-f00c0a7779e6/tag/imdb-sort/

google = require "google"
google.resultsPerPage = 1

cache = {}
loading = {}

done = (key, err, result) ->
  cache[key] = [err, result]
  while loading[key].length
    d = loading[key].pop()
    d err, result
  return

module.exports =
  search: (terms..., d) ->
    key = terms.filter((t)->t).join(' ').toLowerCase()
    if cache[key]
      d.apply null, cache[key]
    if loading[key]
      loading[key].push d
      return
    loading[key] = [d]

    console.log "Google searching IMDB for '#{key}'...".grey
    google "site:www.imdb.com #{key}", (err, next, links) =>
      return done key, err if err
      return done key, "No results for '#{key}'" if links.length is 0
      l = links[0].link
      unless /^http:\/\/www\.imdb\.com\/.*\/(tt\d+)\//.test l
        return done key, "No results for '#{key}' on IMDB.com"
      id = RegExp.$1
      console.log "Retrieving IMDB item '#{id}'...".grey
      request "http://www.omdbapi.com/?i=#{id}", (res) =>
        err = res.body if res.statusCode isnt 200
        try
          result = JSON.parse res.body
        catch e
          err = e unless err
        if Object.keys(result).length is 0
          err = "No data for item '#{id}'"
        done key, err, result
        return
      return
    return
