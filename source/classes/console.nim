import osproc, strformat, strutils, os, times
import iface

import ../config
import ../assets

import zippy/ziparchives

type ConsoleBase* = ref object of RootObj
    name*        : string
    author*      : string
    description* : string
    version*     : string

proc getProjectName(self: ConsoleBase): string = self.name

iface *Console:
    proc getName(): string
    proc getProjectName(): string
    proc publish(source: string): bool
    proc getBinaryName(): string
    proc getIconExtension(): string
    proc getExtension(): string


proc runCommand*(command : string) =
    ## Runs a specified command

    var commandResult = execCmdEx(command)
    if commandResult.exitCode != 0:
        echo(fmt("\nError Code {commandResult.exitCode}: {commandResult.output}"))


proc getBinaryPath*(self : Console) : string =
    ## Returns the full path and name to the expected ELF binary

    return elfPath

proc getBinary*(self : Console) : string =
    ## Returns the full path and name of the ELF binary

    return fmt("{self.getBinaryPath()}/{self.getBinaryName()}")

proc getRomFSDirectory*() : string =
    ## Returns the relative directory to use as the romFS directory
    ## It gets appended to the build directory

    let buildDirectory = getOutputValue("build").getStr()
    let romfsDirectory = getOutputValue("romFS").getStr()

    return fmt("{buildDirectory}/{romfsDirectory}")

proc getBuildDirectory*() : string =
    ## Returns the build directory, relative to the project root

    return getOutputValue("build").getStr()

# method getExtension*(self : Console) : string =
#     var extension = "3dsx"
#     if "Switch" in self.getName():
#         extension = "nro"
#
#     return extension

proc getOutputName*(self : Console) : string =
    ## Returns the filename (with extension)

    return fmt("{self.getProjectName()}.{self.getExtension()}")

proc getBuildBinary*(self : Console) : string =
    ## Returns build binay name (with extension)

    return fmt("{getBuildDirectory()}/SuperGame.{self.getExtension()}")

proc getOutputPath*(self : Console) : string =
    ## Returns the output filename relative to the build directory

    return fmt("{getBuildDirectory()}/{self.getOutputName()}")

proc packGameDirectory*(self: Console, source : string) : bool =
    ## Pack the game directory into the binary data

    write(stdout, "Packing game content.. please wait.. ")
    flushFile(stdout)

    let start = getTime()

    let romFS = fmt("{getRomFSDirectory()}.love")
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
        for _, path in walkDir(getBuildDirectory(), relative = true):
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

proc getIcon*(self : Console) : string =
    ## Returns the relative path to the icon for the project.
    ## If one isn't found, it uses the default icon.

    var extension = self.getIconExtension()

    let path = getBuildValue("icon")
    let filename = fmt("{path}.{extension}")

    if not filename.fileExists():
        writeFile(filename, getAsset(fmt("icon.{extension}")))

    return filename
