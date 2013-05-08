
program = require 'optimist'
SortGroup = require './sort-group'

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
  )

argv = program.argv
if argv.h or argv.help or argv.v or argv.version
  console.log program.help()
  return

new SortGroup argv
