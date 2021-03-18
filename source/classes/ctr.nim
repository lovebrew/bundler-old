import console
export console

import tables
import strutils
import os

## Command line stuff to run
var COMMANDS : Table[string, string]

COMMANDS["texture"] = "tex3ds $1 --format=rgba8888 -z auto -o $2"
COMMANDS["font"]    = "mkbcfnt $1 -o $2"

COMMANDS["meta"]    = "smdhtool --create '$1' '$2' '$3' $4 $5.smdh"

## Applicable conversions n such
let textures = @[".png", ".jpg", ".jpeg"]
let fonts    = @[".ttf", ".otf"]
let sources  = @[".lua", ".t3x", ".bcfnt"]

type
    CTR* = ref object of Console

method compile(self: CTR) =
    createDir("game")

    for path in walkDirRec("TurtleInvaders", relative = true):
        let (dir, name, ext) = splitFile(path)

        if ext in textures:
            echo ext

method getName(self: CTR) : string =
    return "Nintendo 3DS"
