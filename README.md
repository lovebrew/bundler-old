[![CI](https://github.com/lovebrew/lovebrew/actions/workflows/CI.yml/badge.svg)](https://github.com/lovebrew/lovebrew/actions/workflows/CI.yml)

## Installation

The easiest way to "install" LÖVEBrew is from the [releases page](https://github.com/TurtleP/lovebrew/releases). Download the respective platform's release and put it in the following directory for your operating system:

- Windows: `%appdata%/lovebrew/`
- macOS/Linux: `~/.config/lovebrew/`
  - Create this directory and add it to your PATH!

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
