import os
import osproc
import strformat

import ../configure
import ../assetsfile
import ../strings

import iface
import zippy/ziparchives

const BinaryExtensions = @[".3dsx", ".nro"]
const MetadataExtensions = @[".smdh", ".nacp"]

type
    ConsoleBase* = ref object of RootObj

iface *Console:
    proc getBinaryExtension(): string
    proc getConsoleName(): string
    proc getElfBinaryName(): string
    proc getIconExtension(): string
    proc publish(source: string)

proc getElfBinaryPath*(self: Console): string =
    ## Return the full path to the ELF binary

    return (config.binSearchPath / self.getElfBinaryName())

proc getOutputBinaryName*(self: Console): string =
    ## Return the filename with extension (.nro/3dsx)

    return fmt("{config.name}.{self.getBinaryExtension()}")

proc getGenericOutputBinaryPath*(self: Console): string =
    ## Return the full path where the binary is output to
    ## This does not include the file extension

    return (config.build / config.name)

proc getOutputBinaryPath(self: Console): string =
    ## Return the full path to the output binary
    ## This does include the file extension

    return (config.build / self.getOutputBinaryName())

proc preBuildCleanup*() =
    if not config.clean:
        return

    for _, path in os.walkDir(config.build, relative = true):
        let (_, _, extension) = splitFile(path)

        if (extension in BinaryExtensions):
            os.removeFile(config.build / path)

proc postBuildCleanup*() =
    for _, path in os.walkDir(config.build, relative = true):
        let (_, _, extension) = splitFile(path)

        if (extension in MetadataExtensions):
            os.removeFile(config.build / path)

proc getIcon*(self: Console): string =
    ## Return the full path to the icon
    ## If one isn't found, use the default icon

    var extension = self.getIconExtension()
    let filename = fmt("{config.icon}.{extension}")

    var iconData: string
    if not os.fileExists(filename):
        if extension == "nro":
            iconData = assetsfile.DefaultHacIcon
        else:
            iconData = assetsfile.DefaultCtrIcon

        writeFile(filename, iconData)

    return filename

proc packGameDirectory*(self: Console, romFS: string) =
    ## Pack the game directory to the binary
    echo(strings.PackGameFiles)

    let content = fmt("{config.romFS}.love")
    let binaryPath = self.getOutputBinaryPath()

    try:
        ziparchives.createZipArchive(romFS, content)

        let binaryData = readFile(binaryPath)
        writeFile(self.getOutputBinaryPath(), binaryData & readFile(content))

        os.removeFile(content)

        console.postBuildCleanup()
    except Exception:
        return

proc getRomFSDirectory*(): string =
    ## Return the relative "RomFS" directory

    return config.build / config.romFS

proc runCommand*(command: string) =
    ## Runs a specified command
    let result = osproc.execCmdEx(command)

    if result.exitCode != 0:
        echo(result.output)
