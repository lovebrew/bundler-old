import console
export console

import tables
import strutils
import strformat
import os
import system
import times

import ../prompts
import ../config

## Command line stuff to run
let tex_cmd = "tex3ds $1 --format=rgba8888 -z auto --border -o $2.t3x"
let fnt_cmd = "mkbcfnt $1 -o $2.bcfnt"

let meta_cmd = "smdhtool --create '$1' '$2' '$3' '$4' '$5.smdh'"
let bin_cmd  = "3dsxtool $1 '$2.3dsx' --smdh='$2.smdh'"

## Applicable conversions n such
let textures = @[".png", ".jpg", ".jpeg"]
let fonts    = @[".ttf", ".otf"]

type
    CTR* = ref object of Console

{.push base.}

method convertFiles*(self : CTR, source : string) =
    write(stdout, "Converting and copying files.. please wait.. ")
    flushFile(stdout)

    let start = getTime()

    # Get our important directories
    let romFSDirectory = self.getRomFSDirectory()

    # Ensure the required ELF binary exists. If it doesn't, we should abort and inform the user.
    # This should only be an issue if compiling non-raw builds
    let binaryFull = self.getBinary()

    if not binaryFull.fileExists() and not config.getOutputValue("raw").getBool():
        showPromptFormatted("BUILD_FAIL", source, self.getName(), self.getBinaryName(), self.getBinaryPath())
        return

    # Walk through the source directory
    for path in walkDirRec(source, relative = true):
        let (dir, name, extension) = splitFile(path)

        let relativePath = fmt("{source}/{path}")
        let destination = fmt("{romFSDirectory}/{dir}")

        # May or may not be horribly inefficient because it attempt to create all directories
        # for pretty much every file multiple times, but it shouldn't be *that* bad
        createDir(destination)

        # If the file we're currently looking at has its extension in one of these sets, operate on it
        # See the COMMANDS table for more information
        if extension in textures:
            self.runCommand(tex_cmd.format(relativePath, fmt("{destination}/{name}")))
        elif extension in fonts:
            self.runCommand(fnt_cmd.format(relativePath, fmt("{destination}/{name}")))
        else:
            copyFile(relativePath, fmt("{destination}/{name}{extension}"))

    let delta = (getTime() - start).inSeconds()
    echo(fmt("done in {delta}s"))

{.pop base}

method publish(self : CTR, source : string) : bool =
    self.convertFiles(source)

    # If we're building in "raw" mode, don't create a 3dsx
    if config.getOutputValue("raw").getBool():
        return

    let properDescription = fmt("{self.description} • {self.version}")
    let binaryPath = fmt("{self.getBuildDirectory()}/{self.name}")

    # Meta Command
    self.runCommand(meta_cmd.format(self.name, properDescription, self.author, self.getIcon(), binaryPath))

    # Binary Command
    self.runCommand(bin_cmd.format(self.getBinary(), binaryPath))

    if not self.getOutputPath().fileExists():
        return false

    let binaryData = readFile(self.getOutputPath())
    return self.packGameDirectory(binaryData, self.getRomFSDirectory())

method getName(self : CTR) : string =
    return "Nintendo 3DS"
