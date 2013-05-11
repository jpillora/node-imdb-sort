
global.home = process.env.USERPROFILE or process.env.HOME or process.env.HOMEPATH
global.pwd = process.cwd()

require "colors"
path = require 'path'
program = require 'optimist'
SortGroup = require './group'
SortConfig = require './config'
pkg = require "../package.json"

# CLI
program = program.
  usage("""Organises Movies and TV Shows using IMDB v#{pkg.version}
           Usage: imdb-sort [options]""").
  options('c',
    'alias'    : 'config'
    'describe' : 'Path to \'imdb-sort.json\' configuration file'
    'default'  : path.join home, '.imdb-sort', 'config.json'
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
  )

argv = program.argv
if argv.h or argv.help or argv.v or argv.version
  return program.showHelp(console.error)

#resolve relatives
argv.d = argv.directory = path.resolve(argv.d)
argv.c = argv.config    = path.resolve(argv.c)

if argv.p
  console.log "PREVIEW MODE".yellow

if argv.r is true
  argv.r = argv.recursive = 3

SortConfig.load argv, (err, config) ->
  group = new SortGroup argv, config
  group.run()



