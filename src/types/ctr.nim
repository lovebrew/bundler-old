import os
import strutils
import strformat

import console
export console

import ../configure
import ../strings
import ../logger

import ../assetsfile

const TextureCommand = """tex3ds "$1" --format=rgba8888 -z=auto --border -o "$2.t3x""""
const FontCommand = """mkbcfnt "$1" -o "$2.bcfnt""""

const SmdhCommand = """smdhtool --create "$1" "$2" "$3" "$4" "$5.smdh""""
const BinaryCommand = """3dsxtool "$1" "$2.3dsx" --romfs=$3 --smdh="$2.smdh""""

const Textures = @[".png", ".jpg", ".jpeg"]
const Fonts = @[".ttf", ".otf"]

const RomFSDirectory = "romfs/ctr/graphics"

type
    Ctr* = ref object of ConsoleBase

proc getBinaryExtension*(self: Ctr): string = "3dsx"
proc getConsoleName*(self: Ctr): string = "Nintendo 3DS"
proc getElfBinaryName*(self: Ctr): string = "3DS.elf"
proc getIconExtension*(self: Ctr): string = "png"

proc shouldConvertFile(self: Ctr, source: string, destination: string): bool =
    if not fileExists(destination) or fileNewer(source, destination):
        logger.info(fmt"Converting file {source} to {destination}!")
        return true

    return false

proc convertFiles(self: Ctr, source: string): bool =
    echo(strings.ConvertCopyingFiles)

    let romFS = console.getRomFSDirectory()

    for path in os.walkDirRec(source, relative = true):
        if os.isHidden(path):
            continue

        let (dir, name, extension) = os.splitFile(path)

        let relativePath = fmt("{source}/{path}")
        let destination = fmt("{romFS}/{dir}")

        try:
            os.createDir(destination)

            let destinationPath = fmt("{destination}/{name}")

            if extension in Textures or extension in Fonts:
                if not self.shouldConvertFile(relativePath, destinationPath):
                    continue

                var conversion_command: string = ""

                if extension in Textures:
                    conversion_command = TextureCommand.format(relativePath, destinationPath)
                elif extension in Fonts:
                    conversion_command = FontCommand.format(relativePath, destinationPath)
                else:
                    os.copyFileToDir(relativePath, destination)

                if not conversion_command.isEmptyOrWhitespace():
                    runCommand(conversion_command)
        except Exception as e:
            return false

    return true

proc publish*(self: Ctr, source: string): bool =
    if not self.convertFiles(source):
        return

    let elfBinaryPath = self.getElfBinaryPath()

    if not os.fileExists(elfBinaryPath) and not config.rawData:
        echo(strings.ElfBinaryNotFound.format(
                config.name, self.getConsoleName(), self.getElfBinaryName(),
                config.binSearchPath))
        return

    let properDescription = fmt("{config.description} • {config.version}")
    let outputPath = self.getGenericOutputBinaryPath()

    try:
        os.createDir(RomFSDirectory)

        # Copy RomFS graphics content to directory
        for name, content in CtrGraphics.items():
            writeFile(fmt"{RomFSDirectory}/{name}", content)

        let (head, _) = splitPath(RomFSDirectory)

        # Output {SuperGame}.smdh to `build` directory
        console.runCommand(SmdhCommand.format(config.name, properDescription,
                config.author, self.getIcon(), outputPath))

        # Output {SuperGame}.3dsx to `build` directory
        console.runCommand(BinaryCommand.format(self.getElfBinaryPath(),
                outputPath, head))
    except Exception as e:
        logger.error(fmt"{self.getConsoleName()} publishing failure: {e.msg}")
        return false

    let directory = config.build / config.romFS
    return self.packGameDirectory(fmt("{directory}/"))
