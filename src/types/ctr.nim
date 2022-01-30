import os
import strutils
import strformat

import console
import config
import ../data/assets
import ../data/strings
import ../logger
import ../enums/extension

type
    Ctr* = ref object of ConsoleBase

const TextureCommand = """tex3ds "$1" --format=rgba8888 -z=auto --border=transparent -o "$2"""
const FontCommand = """mkbcfnt "$1" -o "$2""""

proc getBinaryExtension*(this: Ctr): string = "3dsx"
proc getConsoleName*(this: Ctr): string = "Nintendo 3DS"
proc getIconExtension*(this: Ctr): string = "png"

proc getDescription(this: Ctr): string =
    fmt("{ConsoleBase(this).getDescription()} • {this.config.metadata.version}")

proc convertFiles(this: Ctr): bool =
    let source = this.config.build.source
    let output = this.config.output.buildDir

    for filepath in os.walkDirRec(source, relative = true):
        if os.isHidden(filepath):
            continue

        let (dir, _, fileExt) = os.splitFile(filepath)

        let relativePath = normalizedPath(source / filepath)
        let destinationDir = normalizedPath(output / dir)

        let filename = os.extractFilename(filepath)

        var destination: string

        try:
            os.createDir(destinationDir)
            destination = normalizedPath(destinationDir / filename)

            let newExtension = extension.getExtension(fileExt)

            if newExtension != Extension.OTHER:
                destination = os.changeFileExt(destination, $newExtension)

            if not console.handleFile(relativePath, destination):
                continue

            var success: bool
            case newExtension:
                of T3X:
                    success = console.execute(TextureCommand.format(
                            relativePath, destination))
                of BCFNT:
                    success = console.execute(FontCommand.format(relativePath, destination))
                else:
                    os.copyFileToDir(relativePath, destinationDir)

            if not success:
                return false

        except IOError as e:
            logger.error(strings.CopyConvertError.format(e.msg, relativePath,
                    destinationDir / destination))
            return false

    return true

proc isRawOutput(this: Ctr): bool =
    return this.config.output.asRaw

proc publish*(this: Ctr): bool =
    logger.info(fmt("== [{this.getConsoleName()}] =="))

    if not this.convertFiles():
        return false

    let name = this.config.metadata.name
    let searchPath = this.config.build.searchPath

    if not this.checkBinaryExists() and not this.isRawOutput():
        echo(strings.ElfBinaryNotFound.format(name, this.getConsoleName(
            ), this.getBinaryName(), searchPath))
        return false

    let description = this.getDescription()
    echo("Description: " & description)

    return true
