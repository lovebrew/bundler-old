# Installation
To get the latest version from Github, just run
```
sudo pip3 install -U git+git://github.com/TurtleP/lovebrew.git
```
and you should be able to run `lovebrew -h`!
# Usage

Once the application is installed, just run `lovebrew` in a directory with your game content that also has `lovebrew.toml` inside.

## Nintendo 3DS
By default, 3DS games will only compile as "raw". This means they only output the converted assets (textures and fonts) with any lua source code. This makes it easy to test games through the `game` directory method.

## Nintendo Switch
Switch games will compile normally; they build into the proper homebrew binary format.

## Options
| Command | Help |
|:--------|:-----|
| -h --help | Show help | 
| -v --verbose | Show logging output |
| -f --fused FUSED | Create a fused game. Pass 'lpx' to only create the romfs (Switch Only) | 
| --version | show program's version number and exit |
| -c --clean | Clean the directory |

## Configuring Builds
See [the template file](lovebrew.toml)
