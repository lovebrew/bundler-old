# Installation
To get the latest version from Github, just run
```
sudo pip3 install -U git + git://github.com/TurtleP/lovebrew.git
```
and you should be able to run `lovebrew -h`!
# Usage

Once the application is installed, just run `lovebrew` in a directory with your game content that also has `lovebrew.toml` inside.

## Nintendo 3DS
By default, 3DS games will only compile as "raw". This means they only output the converted assets (textures and fonts) with any lua source code. This makes it easy to test games through the `game` directory method.

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
