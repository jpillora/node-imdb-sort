

fs = require "fs"
path = require "path"
SortFile = require "./file"

#sorter class
module.exports = class SortGroup

  constructor: (@argv, @config) ->
    @paths = []

  run: ->
    @scanDir @argv.directory

  scanDir: (dir, depth = @argv.r) ->
    return if depth is 0
    files = fs.readdirSync dir
    throw "Read dir: #{dir} failed" unless files

    for f in files
      continue if /^\./.test f
      p = path.join dir,f
      stats = fs.statSync p
      throw "Stat file: #{p} failed" unless stats
      if stats.isDirectory()
        @scanDir p, depth-1
      else
        @paths.push p

    @sortFiles()

  sortFiles: ->
    @paths.sort()

    for p in @paths
      f = new SortFile p, @
      f.run()


