

fs = require "fs"
path = require "path"

module.exports = class SortConfig

  constructor: (@opts) ->

    @path = @opts.path

    @config = fs.readFileSync @path