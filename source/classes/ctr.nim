import strutils, strformat, os

import ../prompts
import ../config/configfile

import console
export console

## Command line stuff to run
let tex_cmd = "tex3ds '$1' --format=rgba8888 -z auto --border -o '$2.t3x'"
let fnt_cmd = "mkbcfnt '$1' -o '$2.bcfnt'"

let meta_cmd = "smdhtool --create '$1' '$2' '$3' '$4' '$5.smdh'"
let bin_cmd  = "3dsxtool '$1' '$2.3dsx' --smdh='$2.smdh'"

## Applicable conversions n such
let textures = @[".png", ".jpg", ".jpeg"]
let fonts    = @[".ttf", ".otf"]

type CTR* = ref object of ConsoleBase

proc getName*(self : CTR) : string = "Nintendo 3DS"
proc getBinaryName*(self : CTR) : string = "3DS.elf"
proc getIconExtension*(self : CTR) : string = "png"
proc getExtension*(self : CTR) : string = "3dsx"
proc convertFiles(self : CTR, source : string) : bool

proc publish*(self : CTR, source : string) : bool =
    if not self.convertFiles(source):
        return false

    # If we're building in "raw" mode, don't create a 3dsx
    if Config.shouldOutputRawData():
        return true

    let properDescription = self.description & " • " & self.version
    let binaryPath        = getBuildDirectory() & "/LOVEPotion"

    try:
        # Meta Command
        runCommand(meta_cmd.format(self.name, properDescription, self.author, self.getIcon(), binaryPath))

        # Binary Command
        runCommand(bin_cmd.format(self.getBinaryPath(), binaryPath))
    except CatchableError as error:
        echo(error.msg)
        return false

    return self.packGameDirectory(getRomFSDirectory())


proc convertFiles(self : CTR, source : string) : bool =
    echo("Converting and copying files..")

    # Get our important directories
    let romFSDirectory = getRomFSDirectory()

    # Ensure the required ELF binary exists. If it doesn't, we should abort and inform the user.
    # This should only be an issue if compiling non-raw builds
    let elfBinaryPath = self.getBinaryPath()

    if not elfBinaryPath.fileExists() and not Config.shouldOutputRawData():
        BUILD_FAIL.showFormatted(source, self.getName(), self.getBinaryName(), self.getBinaryPath())
        return

    # Walk through the source directory
    var hasError = false

    for path in walkDirRec(source, relative = true):
        let (dir, name, extension) = splitFile(path)

        let relativePath = fmt("{source}/{path}")
        let destination = fmt("{romFSDirectory}/{dir}")

        if isHidden(relativePath):
            continue

        # May or may not be horribly inefficient because it attempt to create all directories
        # for pretty much every file multiple times, but it shouldn't be *that* bad
        try:
            createDir(destination)

            # If the file we're currently looking at has its extension in one of these sets, operate on it
            if extension in textures:
                runCommand(tex_cmd.format(relativePath, fmt("{destination}/{name}")))
            elif extension in fonts:
                runCommand(fnt_cmd.format(relativePath, fmt("{destination}/{name}")))
            else:
                copyFile(relativePath, fmt("{destination}/{name}{extension}"))
        except CatchableError as error:
            echo(error.msg)
            hasError = true
            break

    if hasError:
        return false

    return true
