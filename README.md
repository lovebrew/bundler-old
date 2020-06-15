# Installation

## GitHub
To get the latest version from Github, just run
```
sudo pip3 install -U git + git://github.com/TurtleP/lovebrew.git
```

## PyPi
To get the latest version from PyPi, just run
```
sudo pip3 install lovebrew
```
and you should be able to run `lovebrew -h`!

# Usage

Once the application is installed, just run `lovebrew` in a directory with your game content that also has `lovebrew.toml` inside.

## Nintendo Switch
Switch games will compile normally; they build into the proper homebrew binary format.

## Options
```
usage: lovebrew [-h] [-v] [--version] [-c] [-i]

Löve Potion Game Helper

optional arguments:
  -h, --help     show this help message and exit
  -v, --verbose  Show logging output.
  --version      show program's version number and exit
  -c, --clean    Clean the directory
  -i, --init     Initialize a lovebrew config in the current directory
```
