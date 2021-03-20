import osproc
import strformat
import strutils
import os

import ../config
import ../assets

type
    Console* = ref object of RootObj

        name*: string
        author*: string
        description*: string
        version*: string

method runCommand*(self : Console, command : string) {.base.} =
    ## Runs a specified command

    discard execCmd(command)

method compile*(self : Console, source : string) {.base, locks: "unknown".} =
    ## Compiles a 3DS or Switch project -- see child classes for implementation

    echo ""

method getName(self : Console) : string {.base.} =
    ## Returns the console name -- see child classes for implementation

    return "Console"

method getElfBinaryPath*(self : Console) : string {.base.} =
    ## Returns the full path and name to the expected ELF binary

    let expected = self.getName().split(" ")[1]
    return fmt("{elfPath}/{expected}.elf")

method getElfBinaryName*(self : Console) : string {.base.} =
    ## Returns the name of the expected ELF binary
    ## This would be "3DS.elf" or "Switch.elf"

    let expected = self.getName().split(" ")[1]
    return fmt("{expected}.elf")

method getElfBinary*(self : Console) : string {.base.} =
    ## Returns the full path and name of the ELF binary

    return fmt("{self.getElfBinaryPath()}/{self.getElfBinaryName()}")

method getRomFSDirectory*(self : Console) : string {.base.} =
    ## Returns the relative directory to use as the romFS directory
    ## It gets appended to the build directory

    let buildDirectory = getOutputValue("build").getStr()
    let romfsDirectory = getOutputValue("romFS").getStr()

    return fmt("{buildDirectory}/{romfsDirectory}")

method getBuildDirectory*(self : Console) : string {.base.} =
    ## Returns the build directory, relative to the project root

    return getOutputValue("build").getStr()

method getIcon*(self : Console) : string {.base.} =
    ## Returns the relative path to the icon for the project.
    ## If one isn't found, it uses the default icon.

    var suffix = "png"

    if "Switch" in self.getName():
        suffix = "jpg"

    let path = getBuildValue("icon")
    let filename = fmt("{path}.{suffix}")

    if not filename.fileExists():
        writeFile(filename, getAsset(fmt("icon.{suffix}")))

    return filename
