node-imdb-sort
==============

Sort files based on IMDB data

### Usage

1. [Install Node.js](http://nodejs.org/download/)

2. `npm install -g imdb-sort`

3. `cd my-messy-movie-folder`

4. `imdb-sort`

*Note: On first run a setup wizard will run prompting you to create the configuration file below. Default location is `~/.imdb-sort/config.json`*

### Help Output

```
Organises Movies and TV Shows using IMDB
Usage: imdb-sort [options]

Options:
Options:
  -c, --config          Path to 'imdb-sort.json' configuration file             [default: "~/.imdb-sort/config.json"]
  -d, --directory       The directory to scan                                   [default: <CURRENT DIR>]
  -r, --recursive       Recursive depth (default: current directory)            [default: 1]
  -f, --filter          Process filepaths matching this regular expression      [default: null]
  -i, --inverse-filter  Process filepaths not matching this regular expression  [default: null]
  -w, --watch           Watch directory for changes
  -p, --preview         Dry run only (will not move any files)
  -s, --setup           Setup wizard to create or edit the default config
  --debug               Debug mode
```

*Note: If you specify `-r` without a depth; `3` will be used.

### Configuration

Here is my generated `config.json` using default settings

``` json
{
  "replaceExisting": false,
  "tvShows": {
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

* It is possible to get temporarily blocked by Google for sending too many requests.
* `imdb-sort` decides if a file is TV series or Movie depending on whether it can find season and episode numbers. Please post an issue if a TV series file is found to be a movie.

### Todo

* Modify metadata
* Episode names
* Lazy match on subtitles file

### Contributing

The source is CoffeeScript
* Get deps with `npm install`
* Compile with `npm start`
* For testing, make a symbolic link with `ln -s ./bin/imdb-sort [a-folder-in-your-PATH]`

