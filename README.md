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
Organises Movies and TV Shows using IMDB v0.0.2
Usage: imdb-sort [options]

Options:
  -d, --directory  The directory to scan                              [default: "/Volumes/jpillora/Code/Node/node-imdb-sort"]
  -r, --recursive  Recursive depth (default: current directory)       [default: 1]
  -w, --watch      Watch directory for changes                        [default: false]
  -c, --config     Path to 'imdb-sort.json' configuration file        [default: "/Volumes/jpillora/.imdb-sort/config.json"]
  -p, --preview    Dry run only (will not move any files)             [default: false]
  -s, --setup      Setup wizard to create or edit the default config  [default: false]
```

### Configuration

`config.json`

``` json
{
  "replaceExisting": false,
  "tvshows" : {
    "fileName": "{{ Title }} - Season {{ Season }} Episode {{ Episode }}",
    "root": "./TV Shows/",
    "directoryPerShow": true,
    "showName": "{{ Title }}",
    "directoryPerSeason": false,
    "seasonName": "Season {{ Season }}"
  },
  "movies": {
    "fileName": "{{ Title }} ({{ Year }})",
    "root": "./Movies/"
  }
}
```

# Naming Files and Directories

Inside your configuration, `fileName`, `showName` and `seasonName` can be used to customise your naming styles.

Usable template keys are:
``` json
{
  Title: 'Lost',
  Year: '2004',
  Rated: 'TV-14',
  Released: '22 Sep 2004',
  Runtime: '42 min',
  Genre: 'Adventure, Drama, Fantasy, Mystery, Sci-Fi, Thriller',
  Director: 'N/A',
  Writer: 'J.J. Abrams, Jeffrey Lieber',
  Actors: 'Jorge Garcia, Naveen Andrews, Matthew Fox, Josh Holloway',
  Plot: 'The survivors of a plane crash are forced to live with each other on a remote island, a dangerous new world that poses unique threats of its own.',
  Poster: 'http://ia.media-imdb.com/images/M/MV5BMjA3NzMyMzU1MV5BMl5BanBnXkFtZTcwNjc1ODUwMg@@._V1_SX300.jpg',
  imdbRating: '8.3',
  imdbVotes: '141,852',
  imdbID: 'tt0411008',
  Type: 'series',
  Season: 1,
  Episode: 5
}
```

# Contributing

The source is CoffeeScript
* Get deps with `npm install`
* Compile with `npm start`
* For testing, make a symbolic link with `ln -s ./bin/imdb-sort [a-folder-in-your-PATH]`