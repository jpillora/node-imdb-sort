
path = require 'path'

global.home = process.env.USERPROFILE or process.env.HOME or process.env.HOMEPATH
global.defaultConfig = path.join home, '.imdb-sort', 'config.json'
global.pwd = process.cwd()

require "colors"
program = require 'optimist'
SortGroup = require './group'
SortConfig = require './config'
pkg = require "../package.json"

# CLI
program = program.
  usage("""#{'IMDb Sort'.yellow} - v#{pkg.version}
           Organises Movies and TV Shows using IMDB
           Usage: imdb-sort [options]""").
  options('c',
    'alias'    : 'config'
    'describe' : 'Path to \'' + 'imdb-sort' + '.json\' configuration file'
    'default'  : defaultConfig
  ).
  options('d',
    'alias'    : 'directory'
    'describe' : 'The directory to scan'
    'default'  : pwd
  ).
  options('r',
    'alias'    : 'recursive'
    'describe' : 'Recursive depth (default: current directory)'
    'default'  : 1
  ).
  options('f',
    'alias'    : 'filter'
    'describe' : 'Process filepaths matching this regular expression'
    'default'  : null
  ).
  options('i',
    'alias'    : 'inverse-filter'
    'describe' : 'Process filepaths not matching this regular expression'
    'default'  : null
  ).
  options('w',
    'alias'    : 'watch'
    'describe' : 'Watch directory for changes'
  ).
  options('p',
    'alias'    : 'preview'
    'describe' : 'Dry run only (will not move any files)'
  ).
  options('s',
    'alias'    : 'setup'
    'describe' : 'Setup wizard to create or edit the default config'
  ).
  options('debug',
    'describe' : 'Debug mode'
  )

argv = program.argv
if argv.h or argv.help or
   argv.v or argv.version or
   argv._?.length
  program.showHelp(console.error)
  console.log "Did you mean '-d #{argv._[0]}' ?".yellow if argv._?.length
  return

#calculate arguments
argv.d = argv.directory = path.resolve(argv.d)
argv.c = argv.config    = path.resolve(argv.c)
argv.r = argv.recursive = 3 if argv.r is true
try
  argv.i = argv['inverse-filter'] = new RegExp argv.i if argv.i
  argv.f = argv.filter            = new RegExp argv.f if argv.f
catch e
  return console.log "Invalid regex filter: #{e}".red

console.log "DEBUG MODE - ARGS: #{JSON.stringify argv,null,2}" if argv.debug
console.log "PREVIEW MODE".yellow if argv.p

#load config then run
SortConfig.load argv, (err, config) ->
  return console.log "Error loading config: #{err}" if err
  group = new SortGroup argv, config
  group.run()



