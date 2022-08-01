# Package

version = "0.6.0"
author = "TurtleP"
description = "LÖVE Potion Game Distribution Helper"
license = "MIT"
srcDir = "src"
bin = @["lovebrew"]
binDir = "dist"


# Dependencies

requires "nim >= 1.6.0"
requires "zippy"
requires "parsetoml"
requires "cligen"
