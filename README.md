node-imdb-sort
==============

Sort files based on IMDB data

### Usage

1. `npm install -g imdb-sort`

2. `cd my-messy-movie-folder`

3. `imdb-sort`

*Note: On first run a setup wizard will run prompting you to create the configuration file below. Default location is `~/.imdb-sort/config.json`*

### Help Output

```
Organises Movies and TV Shows using IMDB v0.0.4
Usage: imdb-sort [options]

Options:
  -c, --config     Path to 'imdb-sort.json' configuration file        [default: "/Volumes/jpillora/.imdb-sort/config.json"]
  -d, --directory  The directory to scan                              [default: "/Volumes/jpillora/Code/Node/node-imdb-sort"]
  -r, --recursive  Recursive depth (default: current directory)       [default: 1]
  -w, --watch      Watch directory for changes
  -p, --preview    Dry run only (will not move any files)
  -s, --setup      Setup wizard to create or edit the default config
```

*Note: If you specific `-r` without a depth; `3` will be used.

### Configuration

Here is my generated `config.json` using default settings

``` json
{
  "replaceExisting": false,
  "tvshows": {
    "root": "/Volumes/jpillora/Movies/TV Shows",
    "fileName": "{{ Title }} - Season {{ Season }} Episode {{ Episode }}",
    "directoryPerShow": true,
    "showName": "{{ Title }}",
    "directoryPerSeason": false,
    "seasonName": "Season {{ Season }}"
  },
  "movies": {
    "root": "/Volumes/jpillora/Movies/Movies",
    "fileName": "{{ Title }} ({{ Year }})"
  }
}
```

### Naming Files and Directories

Inside your configuration, `fileName`, `showName` and `seasonName` can be used to customise your naming styles.

Usable template keys are: `Title`,`Year`,`Season`,`Episode`,`Rated`,`Released`,`Runtime`,`Genre`,`Director`,`Writer`,`Actors`,`Plot`,`Poster`,`imdbRating`,`imdbVotes`,`imdbID`,`Type`

### Known Issues

It is possible to get temporarily blocked by Google for sending too many requests.

### Todo

* Modify metadata
* Episode names
* Lazy match on subtitles file

### Contributing

The source is CoffeeScript
* Get deps with `npm install`
* Compile with `npm start`
* For testing, make a symbolic link with `ln -s ./bin/imdb-sort [a-folder-in-your-PATH]`

