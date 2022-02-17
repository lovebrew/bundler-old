import os
import strutils
import strformat

include console

import ../data/assets
import ../enums/command
import ../enums/extension

type
    Ctr* = ref object of Console

method getBinaryExtension(this: Ctr): string = "3dsx"
method getConsoleName*(this: Ctr): string = "Nintendo 3DS"
method getIconExtension(this: Ctr): string = "png"
method getFileExtensions(this: Ctr): array[0x02, string] = [".3dsx", ".smdh"]

method convertFiles(this: Ctr, source: string,
        buildDir: string): bool {.base.} =
    logger.info($LogData.CopyConvertFiles)

    for filepath in os.walkDirRec(source, relative = true):
        if os.isHidden(filepath):
            continue

        let parent = os.parentDir(filepath)

        let relativePath = (source / filepath)
        let destinationDir = (buildDir / parent)

        let filename = os.extractFilename(filepath)
        var destination: string

        try:
            os.createDir(destinationDir)

            # Replace the filename extension as needed
            destination = destinationDir / extension.replace(filename)

            # Check if the file is newer
            if not this.handleFile(relativePath, destination):
                continue

            var success: bool = true
            # Handle copy or convert
            case fromExtension(filepath):
                of Extension.T3x:
                    success = command.run($Command.Tex3ds, relativePath, destination)
                of Extension.Bcfnt:
                    success = command.run($Command.MkBcfnt, relativePath, destination)
                else:
                    os.copyFile(relativePath, destination)

            if not success:
                return false

        except IOError as e:
            logger.error(formatLog(LogData.CopyConvertError, relativePath, e.msg))
            return false

    return true

method publish*(this: Ctr, cfg: Config): bool =
    logger.info(formatLog(LogData.InitializeBuild, this.getConsoleName()))

    let buildDir = cfg.output.buildDir / cfg.output.gameDir

    # Convert and/or copy files
    if not this.convertFiles(cfg.build.source, buildDir):
        return false

    # Build the zip file
    if not this.packGameFiles(cfg.metadata.name, buildDir, cfg.output.buildDir):
        return false

    return true
