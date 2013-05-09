

fs = require "fs"
path = require "path"

module.exports =

  load: (@argv, @done) ->
    @path = @argv.config
    console.log "Using config '#{@path}'...".grey
    if fs.existsSync @path
      @read()
    else
      @gen()



  gen: ->
    console.log "Config generation not implemented".red
    process.exit(1)
    # get user input to first fill config
    #       mac     pc
    # HOME/Movies|Videos/Movies|TV Shows
  read: ->
    contents = fs.readFileSync @path
    return @done "Cannot read: #{@path}" unless contents

    try
      @config = JSON.parse contents
    catch e
      return @done e

    #ready
    @done null, @config
