[![CI](https://github.com/lovebrew/lovebrew/actions/workflows/CI.yml/badge.svg)](https://github.com/lovebrew/lovebrew/actions/workflows/CI.yml)

## Installation

The easiest way to "install" LÖVEBrew is from the [releases page](https://github.com/TurtleP/lovebrew/releases). Download the respective platform's release and put it in the following directory for your operating system:

- Windows: `%appdata%/lovebrew/bin`
- macOS/Linux: `~/.config/lovebrew/bin`
  - Create this directory and add it to your PATH!

## Dependencies

Some things are required to be installed/added for LÖVEBrew to function properly. Specifically install these packages [from devkitpro-pacman](https://devkitpro.org/wiki/devkitPro_pacman):

Building for Nintendo 3DS:

- `tex3ds`

One binary not provided by devkitpro-pacman:

- [`hbupdater`](https://github.com/TurtleP/hbupdater)

## Building a Project

LÖVEBrew will look for the LÖVE Potion binaries by default in the OS configuration directory. However, you _can_ override this setting inside the config file and it will search relative to the project's root. The config directory is at the following locations:

- Windows: `%appdata%/lovebrew`
- Linux and macOS: `~/.config/lovebrew`

## Options

```
Usage:
  lovebrew {SUBCMD}  [sub-command options & parameters]
where {SUBCMD} is one of:
  help     print comprehensive or per-cmd help
  init     Initializes a new config file
  build    Build the project for the current targets in the config file
  clean    Clean the output directory
  version  Show program version and exit

lovebrew {-h|--help} or with no args at all prints this message.
lovebrew --help-syntax gives general cligen syntax help.
Run "lovebrew {help SUBCMD|SUBCMD --help}" to see help for just SUBCMD.
Run "lovebrew help" to get *comprehensive* help.
```

## Development

- To build the program do `nimble build`
- To build and run, do `nimble run`
