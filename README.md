## Installation
The easiest way to "install" LÖVEBrew is from the [releases page](https://github.com/TurtleP/lovebrew/releases). Download the respective platform's release and put it in the following directory for your operating system:

- Windows: `%appdata%/lovebrew`
  - Create this directory and add it to your PATH!
- Linux: `/usr/bin`
- macOS: TBD

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
