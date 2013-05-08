
path = require 'path'
program = require 'optimist'
SortGroup = require './sort-group'

home = process.env.HOME or process.env.HOMEPATH or process.env.USERPROFILE

# CLI
program = program.
  usage("""Organises Movies and TV Shows using IMDB.
           Usage: imdb-sort [Options]
           Version: 0.0.1""").
  options('d',
    'alias'    : 'directory'
    'describe' : 'The directory to scan'
    'default'  : process.cwd()
  ).
  options('r',
    'alias'    : 'recursive'
    'describe' : 'Scan subdirectories'
    'default'  : false
  ).
  options('w',
    'alias'    : 'watch'
    'describe' : 'Watch directory for changes'
    'default'  : false
  ).
  options('c',
    'alias'    : 'config'
    'describe' : '\'imdb-sort\' configuration file'
    'default'  : path.join home, 'imdb-sort.json'
  )

argv = program.argv
if argv.h or argv.help or argv.v or argv.version
  console.log program.help()
  return

Config = new SortConfig argv
Group = new SortGroup argv

#runs...
