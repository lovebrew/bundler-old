import osproc
import strformat
import strutils
import os
import times

import ../config
import ../assets
import ../prompts

import zippy/ziparchives

type
    Console* = ref object of RootObj

        name*        : string
        author*      : string
        description* : string
        version*     : string

method runCommand*(self : Console, command : string) {.base.} =
    ## Runs a specified command

    var commandResult = execCmdEx(command)

    if commandResult.exitCode != 0:
        echo(fmt("\nError Code {commandResult.exitCode}: {commandResult.output}"))

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

method getOutputName(self : Console) : string =
    ## Returns the filename (with extension)

    var extension = "3dsx"
    if "Switch" in self.getName():
        extension = "nro"

    return fmt("{self.name}.{extension}")

method getOutputPath*(self : Console) : string {.base.} =
    ## Returns the output filename relative to the build directory

    return fmt("{self.getBuildDirectory()}/{self.getOutputName()}")

method packGameDirectory*(self: Console, binaryData : string, source : string) : bool {.base.} =
    ## Pack the game directory into the binary data

    write(stdout, "Packing game content.. please wait.. ")
    flushFile(stdout)

    let start = getTime()

    let romFS = fmt("{self.getRomFSDirectory()}.love")
    let sourceDirectory = fmt("{source}/")

    var extension = "3dsx"
    if "Switch" in self.getName():
        extension = "nro"

    let binaryPath = fmt("{self.getBuildDirectory()}/{self.getBinaryName()}")

    try:
        writeFile(binaryPath, binaryData)
        createZipArchive(sourceDirectory,  romFS)

        # Run the command to append the zip data to the binary
        var command = fmt("$1 '{binaryPath}' $2 '{romFS}' $3 '{self.getOutputPath()}'")

        when defined(Windows):
            self.runCommand(command.format("copy /b", "+", ""))
        when defined(MacOS) or defined(MacOSX) or defined(Linux):
            self.runCommand(command.format("cat", "", ">"))

        removeFile(romFS)
        removeFile(binaryPath)
    except Exception:
        return false

    let delta = (getTime() - start).inSeconds()
    echo(fmt("done in {delta}s"))

    return true

method publish*(self : Console, source : string) : bool {.base, locks: "unknown".} =
    ## Compiles a 3DS or Switch project -- see child classes for implementation

    if not source.dirExists():
        showPrompt("SOURCE_NOT_FOUND")
        return false

    # Create the romFS directory
    createDir(self.getRomFSDirectory())
    return true

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
