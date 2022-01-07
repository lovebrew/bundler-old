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

proc shouldHandleFile(self: Ctr, source: string, destination: string, ext: string): bool =
    let checked_file = fmt"{destination}.{ext}"

    try:
        if not fileExists(checked_file) or fileNewer(source, checked_file):
            logger.info(fmt"Copying/Converting file {source} to {checked_file}.")
            return true
    except Exception as e:
        logger.error(fmt"Something went wrong: {e.msg} ({checked_file})")

    logger.info(fmt"File source {source} for {checked_file} is not newer. Skipping.")
    return false

proc convertFiles(self: Ctr, source: string): bool =
    stdout.write(strings.ConvertCopyingFiles)

    let romFS = console.getRomFSDirectory()

    for path in os.walkDirRec(source, relative = true):
        if os.isHidden(path):
            continue

        let (dir, name, extension) = os.splitFile(path)

        let relativePath = normalizedPath(fmt("{source}/{path}"))
        let destination = fmt("{romFS}/{dir}")

        var destinationPath: string = ""

        try:
            os.createDir(destination)

            destinationPath = normalizedPath(fmt("{destination}/{name}"))

            if extension in Textures or extension in Fonts:
                let ext = if extension in Textures: "t3x" else: "bcfnt"

                if not self.shouldHandleFile(relativePath, destinationPath, ext):
                    continue

                var conversion_command: string = ""

                if extension in Textures:
                    conversion_command = TextureCommand.format(relativePath, destinationPath)
                elif extension in Fonts:
                    conversion_command = FontCommand.format(relativePath, destinationPath)

                if not conversion_command.isEmptyOrWhitespace():
                    if not runCommand(conversion_command):
                        return false
            else:
                if not self.shouldHandleFile(relativePath, destinationPath, extension.substr(1)):
                    continue

                os.copyFileToDir(relativePath, destination)
        except Exception as e:
            logger.error(fmt"Copy or conversion error! {e.msg}: {relativePath} -> {destination}/{destinationPath}")
            return false

    echo("Done!")
    return true

proc publish*(self: Ctr, source: string): bool =
    logger.info(fmt"== [{self.getConsoleName()}] ==")

    if not self.convertFiles(source):
        return false

    let elfBinaryPath = self.getElfBinaryPath()

    if not os.fileExists(elfBinaryPath) and not config.rawData:
        echo(strings.ElfBinaryNotFound.format(config.name, self.getConsoleName(), self.getElfBinaryName(), config.binSearchPath))
        return false

    let properDescription = fmt("{config.description} • {config.version}")
    let outputPath = self.getGenericOutputBinaryPath()

    try:
        os.createDir(RomFSDirectory)

        # Copy RomFS graphics content to directory
        for name, content in CtrGraphics.items():
            if not fileExists(fmt"{RomFSDirectory}/{name}"):
                writeFile(fmt"{RomFSDirectory}/{name}", content)
            else:
                logger.info(fmt"Messagebox texture '{name}' already exists. Skipping.")

        let (head, _) = splitPath(RomFSDirectory)

        # Output {SuperGame}.smdh to `build` directory
        if not console.runCommand(SmdhCommand.format(config.name, properDescription, config.author, self.getIcon(), outputPath)):
            return false

        # Output {SuperGame}.3dsx to `build` directory
        if not console.runCommand(BinaryCommand.format(self.getElfBinaryPath(), outputPath, head)):
            return false
    except Exception as e:
        logger.error(fmt"{self.getConsoleName()} publishing failure: {e.msg}")
        return false

    let directory = config.build / config.romFS
    return self.packGameDirectory(fmt("{directory}/"))
