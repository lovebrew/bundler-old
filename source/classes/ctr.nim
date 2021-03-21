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
    # Get our important directories
    let romFSDirectory = self.getRomFSDirectory()
    let buildDirectory = self.getBuildDirectory()

    # Create the romFS directory
    createDir(romFSDirectory)

    # Walk through the source directory
    for path in walkDirRec(source, relative = true):
        let (dir, name, extension) = splitFile(path)

        if ignoreList.anyIt(it.find(path) != -1):
            continue

        let relativePath = fmt("{source}/{path}")
        let destination = fmt("{romFSDirectory}/{dir}")

        # May or may not be horribly inefficient because it attempt to create all directories
        # for pretty much every file multiple times, but it shouldn't be *that* bad
        createDir(destination)

        # If the file we're currently looking at has its extension in one of these sets, operate on it
        # See the COMMANDS table for more information
        if extension in textures:
            self.runCommand(COMMANDS["texture"].format(relativePath, fmt("{destination}/{name}")))
        elif extension in fonts:
            self.runCommand(COMMANDS["font"].format(relativePath, fmt("{destination}/{name}")))
        elif extension in sources:
            copyFile(relativePath, fmt("{destination}/{name}{extension}"))

    # If we're building in "raw" mode, don't create a
    # smdh or 3dsx
    if config.getOutputValue("raw").getBool():
        return

    # Create the smdh metadata
    let outputFile = fmt("{buildDirectory}/{self.name}")
    let properDescription = fmt("{self.description} • {self.version}")

    let elfBinaryFull = self.getElfBinary()

    # Ensure the required ELF binary exists. If it doesn't, we should abort and inform the user.
    if not elfBinaryFull.fileExists():
        echo(fmt("The ELF Binary ({self.getElfBinaryName()}) at path {self.getElfBinaryPath()} does not exist! Aborting!"))
        return

    self.runCommand(COMMANDS["meta"].format(self.name, properDescription, self.author, self.getIcon(), outputFile))

    # Create the 3dsx binary
    self.runCommand(COMMANDS["binary"].format(elfBinaryFull, outputFile, self.getRomFSDirectory()))

method getName(self : CTR) : string =
    return "Nintendo 3DS"
