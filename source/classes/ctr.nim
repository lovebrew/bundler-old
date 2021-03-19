import console
export console

import tables
import sequtils
import strutils
import strformat
import os

import ../config

## Command line stuff to run
var COMMANDS : Table[string, string]

COMMANDS["texture"] = "tex3ds $1 --format=rgba8888 -z auto -o $2.t3x"
COMMANDS["font"]    = "mkbcfnt $1 -o $2.bcfnt"

COMMANDS["meta"]    = "smdhtool --create '$1' '$2' '$3' $4 '$5'.smdh"
COMMANDS["binary"]  = "3dsxtool $1 $2.3dsx --smdh=$2.smdh --romfs=$3"

## Applicable conversions n such
let textures = @[".png", ".jpg", ".jpeg"]
let fonts    = @[".ttf", ".otf"]
let sources  = @[".lua", ".t3x", ".bcfnt"]

type
    CTR* = ref object of Console

method compile(self : CTR, source : string) =
    let buildDirectory = getOutputValue("build")

    for path in walkDirRec(source, relative = true):
        let (dir, name, extension) = splitFile(path)

        if ignoreList.anyIt(it.find(path) != -1):
            continue

        let relativePath = fmt("{source}/{path}")
        let destination = fmt("{buildDirectory}/{dir}")

        createDir(destination)

        if extension in textures:
            self.runCommand(COMMANDS["texture"].format(relativePath, fmt("{destination}/{name}")))
        elif extension in fonts:
            self.runCommand(COMMANDS["font"].format(relativePath, fmt("{destination}/{name}")))
        elif extension in sources:
            copyFile(relativePath, fmt("{destination}/{name}{extension}"))

    ## Building in "raw" mode
    if config.getOutputValue("raw").parseBool():
        return

    ## Create the smdh metadata
    let metaFile = fmt("{buildDirectory}/{self.name}")
    self.runCommand(COMMANDS["meta"].format(self.name, self.description, self.author, self.version, self.getIcon(), metaFile))

    ## Create the 3dsx binary
    let elfBinary = fmt("{config.elfPath}/3DS.elf")
    self.runCommand(COMMANDS["binary"].format(elfBinary, metaFile, buildDirectory))

method getName(self : CTR) : string =
    return "Nintendo 3DS"
