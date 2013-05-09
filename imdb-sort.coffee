
require "colors"
path = require 'path'
program = require 'optimist'
SortGroup = require './sort/group'
SortConfig = require './sort/config'

home = process.env.HOME or process.env.HOMEPATH or process.env.USERPROFILE

# CLI
program = program.
  usage("""Organises Movies and TV Shows using IMDB v0.0.1
           Usage: imdb-sort [Options]""").
  options('d',
    'alias'    : 'directory'
    'describe' : 'The directory to scan'
    'default'  : process.cwd()
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
  ). # 'Code', 'Node', 'node-imdb-sort', 'example',
  options('p',
    'alias'    : 'preview'
    'describe' : 'Print to console instead of moving files'
    'default'  : false
  )

argv = program.argv
if argv.h or argv.help or argv.v or argv.version
  console.log "#{program.help()}".cyan
  return

SortConfig.load argv, (err, config) ->
  group = new SortGroup argv, config
  group.run()



