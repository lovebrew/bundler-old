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

{.push base.}

proc runCommand*(command : string) =
    ## Runs a specified command

    var commandResult = execCmdEx(command)

    if commandResult.exitCode != 0:
        echo(fmt("\nError Code {commandResult.exitCode}: {commandResult.output}"))

method getName*(self : Console) : string =
    ## Returns the console name -- see child classes for implementation

    return "Console"

method getBinaryPath*(self : Console) : string =
    ## Returns the full path and name to the expected ELF binary

    return elfPath

method getBinaryName*(self : Console) : string =
    ## Returns the name of the expected ELF binary
    ## This would be "3DS.elf" or "Switch.elf"

    var name = "3DS"
    if "Switch" in self.getName():
        name = "Switch"

    return fmt("{name}.elf")

method getBinary*(self : Console) : string =
    ## Returns the full path and name of the ELF binary

    return fmt("{self.getBinaryPath()}/{self.getBinaryName()}")

method getRomFSDirectory*(self : Console) : string =
    ## Returns the relative directory to use as the romFS directory
    ## It gets appended to the build directory

    let buildDirectory = getOutputValue("build").getStr()
    let romfsDirectory = getOutputValue("romFS").getStr()

    return fmt("{buildDirectory}/{romfsDirectory}")

method getBuildDirectory*(self : Console) : string =
    ## Returns the build directory, relative to the project root

    return getOutputValue("build").getStr()

method getExtension*(self : Console) : string =
    var extension = "3dsx"
    if "Switch" in self.getName():
        extension = "nro"

    return extension

method getOutputName(self : Console) : string =
    ## Returns the filename (with extension)

    return fmt("{self.name}.{self.getExtension()}")

method getBuildBinary*(self : Console) : string =
    ## Returns build binay name (with extension)

    return fmt("{self.getBuildDirectory()}/SuperGame.{self.getExtension()}")

method getOutputPath*(self : Console) : string =
    ## Returns the output filename relative to the build directory

    return fmt("{self.getBuildDirectory()}/{self.getOutputName()}")

method packGameDirectory*(self: Console, source : string) : bool =
    ## Pack the game directory into the binary data

    write(stdout, "Packing game content.. please wait.. ")
    flushFile(stdout)

    let start = getTime()

    let romFS = fmt("{self.getRomFSDirectory()}.love")
    let sourceDirectory = fmt("{source}/")

    let binaryPath = self.getBuildBinary()

    try:
        createZipArchive(sourceDirectory, romFS)

        # Run the command to append the zip data to the binary
        var command = fmt("$1 '{binaryPath}' $2 '{romFS}' $3 '{self.getOutputPath()}'")

        when defined(Windows):
            runCommand(command.format("copy /b", "+", ""))
        when defined(MacOS) or defined(MacOSX) or defined(Linux):
            runCommand(command.format("cat", "", ">"))

        let cleanup = [".smdh", ".nacp"]
        for _, path in walkDir(self.getBuildDirectory(), relative = true):
            let (_, name, extension) = splitFile(path)

            if extension in cleanup or "SuperGame" in name:
                removeFile(path)

        removeFile(romFS)
    except Exception as e:
        echo(e.msg)
        return false

    let delta = (getTime() - start).inSeconds()
    echo(fmt("done in {delta}s"))

    return true

method publish*(self : Console, source : string) : bool =
    ## Compiles a 3DS or Switch project -- see child classes for implementation

    if not source.dirExists():
        SOURCE_NOT_FOUND.show()
        return false

    # Create the romFS directory
    createDir(self.getRomFSDirectory())
    return true

method getIcon*(self : Console) : string =
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

{.pop base}
