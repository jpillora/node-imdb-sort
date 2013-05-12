
http = require "http"
request = (url, done) ->
  throw "Invalid URL" unless (m = url.match /^http:\/\/([^\/]+)(.*)/)
  http.request({ host:m[1], path:m[2] }, (res) ->
    str = ''
    res.on 'data', (c) -> str += c
    res.on 'end', -> res.body = str; done res
  ).end()

google = require "google"
google.resultsPerPage = 1

cache = {}
loading = {}



module.exports =

  search: (title, pref, done) ->

    key = "#{title} #{pref}".toLowerCase()

    if cache[key]
      done null, cache[key]

    if loading[key]
      loading[key].push done
      return

    loading[key] = [done]

    console.log "Google searching IMDB for '#{key}'...".grey
    google "site:www.imdb.com #{key}", (err, next, links) =>
      return done err if err
      return done "No results for '#{key}'" if links.length is 0
      l = links[0].link
      m = l.match /^http:\/\/www\.imdb\.com\/.*\/(tt\d+)\//
      return done "Could not find '#{title}' on IMDB" unless m
      id = m[1]
      console.log "Retrieving IMDB item '#{id}'...".grey
      request "http://www.omdbapi.com/?i=#{id}", (res) =>

        err = res.body if res.statusCode isnt 200

        try
          result = JSON.parse res.body
        catch e
          err = e unless err

        if Object.keys(result).length is 0
          err = "No data for item '#{id}'"

        unless err
          cache[key] = result

        for done in loading[key]
          done err, result



