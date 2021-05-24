# Package

version       = "0.1.0"
author        = "TurtleP & ajusa"
description   = "LÖVE Potion Game Distribution Helper"
license       = "MIT"
srcDir        = "source"
bin           = @["lovebrew"]


# Dependencies

requires "nim >= 1.5.0"
requires "zippy"
requires "parsetoml"
requires "https://github.com/yglukhov/iface"
