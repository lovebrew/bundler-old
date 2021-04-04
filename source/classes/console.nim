import osproc
import strformat
import strutils
import os

import ../config
import ../assets
import ../prompts

type
    Console* = ref object of RootObj

        name*        : string
        author*      : string
        description* : string
        version*     : string

method runCommand*(self : Console, command : string) {.base.} =
    ## Runs a specified command

    discard execCmdEx(command)

method getName*(self : Console) : string {.base.} =
    ## Returns the console name -- see child classes for implementation

    return "Console"

method getBinaryPath*(self : Console) : string {.base.} =
    ## Returns the full path and name to the expected ELF binary

    return elfPath

method getBinaryName*(self : Console) : string {.base.} =
    ## Returns the name of the expected ELF binary
    ## This would be "3DS.elf" or "Switch.elf"

    var extension = "3dsx"
    if "Switch" in self.getName():
        extension = "nro"

    return fmt("LOVEPotion.{extension}")

method getBinary*(self : Console) : string {.base.} =
    ## Returns the full path and name of the ELF binary

    return fmt("{self.getBinaryPath()}/{self.getBinaryName()}")

method getRomFSDirectory*(self : Console) : string {.base.} =
    ## Returns the relative directory to use as the romFS directory
    ## It gets appended to the build directory

    let buildDirectory = getOutputValue("build").getStr()
    let romfsDirectory = getOutputValue("romFS").getStr()

    return fmt("{buildDirectory}/{romfsDirectory}")

method getBuildDirectory*(self : Console) : string {.base.} =
    ## Returns the build directory, relative to the project root

    return getOutputValue("build").getStr()

method publish*(self : Console, source : string) {.base, locks: "unknown".} =
    ## Compiles a 3DS or Switch project -- see child classes for implementation

    if not source.dirExists():
        showPrompt("SOURCE_NOT_FOUND")
        return

    # Create the romFS directory
    createDir(self.getRomFSDirectory())

method getIcon*(self : Console) : string {.base.} =
    ## Returns the relative path to the icon for the project.
    ## If one isn't found, it uses the default icon.

    var extension = "png"

    if "Switch" in self.getName():
        extension = "jpg"

    let path = getBuildValue("icon")
    let filename = fmt("{path}.{extension}")

    if not filename.fileExists():
        writeFile(filename, getAsset(fmt("icon.{extension}")))

    return filename
