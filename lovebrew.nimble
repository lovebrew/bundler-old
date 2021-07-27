# Package

version     = "0.5.0"
author      = "TurtleP"
description = "LÖVE Potion Game Distribution Helper"
license     = "MIT"
srcDir      = "src"
bin         = @["lovebrew"]
binDir      = "dist"


# Dependencies

requires "nim >= 1.5.0"
requires "zippy"
requires "parsetoml"
requires "cligen"
requires "https://github.com/yglukhov/iface"
