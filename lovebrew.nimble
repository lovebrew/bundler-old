# Package

version = "0.7.0"
author = "TurtleP"
description = "LÖVE Potion Game Distribution Helper"
license = "MIT"
srcDir = "src"
bin = @["lovebrew"]
binDir = "dist"


# Dependencies

requires "nim >= 1.6.0"
requires "cligen"
requires "toml_serialization"
requires "zippy"
