[![CI](https://github.com/lovebrew/lovebrew/actions/workflows/CI.yml/badge.svg)](https://github.com/lovebrew/lovebrew/actions/workflows/CI.yml)

## Installation

The easiest way to "install" LÖVEBrew is from the [releases page](https://github.com/TurtleP/lovebrew/releases). Download the respective platform's release and put it in the following directory for your operating system:

- Windows: `%appdata%/lovebrew/`
- macOS/Linux: `~/.config/lovebrew/`
  - Create this directory and add it to your PATH!

## Options

```
usage: lovebrew [-h] [-init] [-build [APP_VERSION]] [--version]

options:
  -h, --help            show this help message and exit
  -init, -i             create a new config
  -build [APP_VERSION], -b [APP_VERSION]
                        build a project
  --version             show program's version number and exit
```

## Development

- To build the program do `nimble build`
- To build and run, do `nimble run`
