
require "colors"
fs = require "fs"
path = require "path"
SortFile = require "./sort-file"

#sorter class
module.exports = class SortGroup

  constructor: (@argv) ->
    @paths = []
    @recursiveDepth = if @argv.r then 3 else 1
    @scanDir @argv.directory

  scanDir: (dir, depth = @recursiveDepth) ->
    return if depth is 0
    files = fs.readdirSync dir
    throw "Read dir: #{dir} failed" unless files

    for f in files
      console.log f
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
      console.log p.yellow
    # new SortFile p