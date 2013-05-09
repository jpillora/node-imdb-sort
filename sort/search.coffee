
request = require "request"
google = require "google"
google.resultsPerPage = 1

cache = {}
loading = {}

module.exports =


  search: (title, pref, done) ->

    key = "#{title} #{pref}".toLowerCase()

    if cache[key]
      done null, cache[title]

    if loading[key]
      loading[key].push done
      return

    loading[key] = [done]

    console.log "Google searching IMDB for '#{key}'...".grey
    google "site:www.imdb.com #{key}", (err, next, links) =>
      throw err if err
      l = links[0].link
      m = l.match /^http:\/\/www\.imdb\.com\/.*\/(tt\d+)\//
      unless m
        console.log "Could not find '#{title}' on IMDB".grey
        return
      id = m[1]
      console.log "Retrieving IMDB item '#{id}'...".grey
      request.get "http://www.omdbapi.com/?i=#{id}", (err, res) =>
        try
          result = JSON.parse res.body
        catch e
          err = e unless err

        unless err
          cache[key] = result

        for done in loading[key]
          done err, result



