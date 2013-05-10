
require "colors"
path = require 'path'
program = require 'optimist'
SortGroup = require './sort/group'
SortConfig = require './sort/config'

global.home = process.env.HOME or process.env.HOMEPATH or process.env.USERPROFILE
global.pwd = process.cwd()

# CLI
program = program.
  usage("""Organises Movies and TV Shows using IMDB v0.0.1
           Usage: imdb-sort [options]""").
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
    'default'  : false
  ).
  options('c',
    'alias'    : 'config'
    'describe' : 'Path to \'imdb-sort.json\' configuration file'
    'default'  : path.join home, '.imdb-sort', 'config.json'
  ).
  options('p',
    'alias'    : 'preview'
    'describe' : 'Dry run only (will not move any files)'
    'default'  : false
  ).
  options('s',
    'alias'    : 'setup'
    'describe' : 'Setup wizard to create or edit the default config'
    'default'  : false
  )

argv = program.argv
if argv.h or argv.help or argv.v or argv.version
  return program.showHelp(console.error)

#resolve relatives
argv.d = argv.directory = path.resolve(argv.d)
argv.c = argv.config    = path.resolve(argv.c)

SortConfig.load argv, (err, config) ->
  group = new SortGroup argv, config
  group.run()



