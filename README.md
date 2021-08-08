## Installation

The easiest way to "install" LÖVEBrew is from the [releases page](https://github.com/TurtleP/lovebrew/releases). Download the respective platform's release and put it in the following directory for your operating system:

* Windows: `%appdata%/lovebrew/bin`
  + Create this directory and add it to your PATH!
* Linux: `/usr/bin`
* macOS: TBD

## Building a Project

LÖVEBrew will look for the LÖVE Potion ELF binaries by default in the OS configuration directory. They must be named accordingly as `3DS.elf` or `Switch.elf` , depending on the build targets.
However, you *can* override this setting inside the config file and it will search relative to the project's root. The config directory is at the following locations:

* Windows: `%appdata%/lovebrew`
* Linux and macOS: `~/.config/lovebrew`

## Options

```
Usage:
  main {SUBCMD}  [sub-command options & parameters]
where {SUBCMD} is one of:
  help     print comprehensive or per-cmd help
  init     Initializes a new config file
  build    Build the project for the current targets in the config file
  clean    Clean the set output directory
  version  Show version info and exit

main {-h|--help} or with no args at all prints this message.
main --help-syntax gives general cligen syntax help.
Run "main {help SUBCMD|SUBCMD --help}" to see help for just SUBCMD.
Run "main help" to get *comprehensive* help.
```

## Development

- To build the program do `nimble build`
- To build and run, do `nimble run`
