# Installation
1. Clone the repository
2. Change your directory to where `setup.py` is
3. Run `sudo pip install -U .`

# Usage

## Nintendo 3DS
By default, 3DS games will only compile as "raw". This means they only output the converted assets (textures and fonts) with any lua source code. This makes it easy to test games through the `game` directory method.

## Nintendo Switch
Switch games will compile normally; they build into the proper homebrew binary format.

Once the application is installed, just run `lovebrew` in a directory with your game content that also has `lovebrew.toml` inside.

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
