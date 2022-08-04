import os
import strformat
import strutils

import ../enums/command
import ../enums/extension

import ../data/strings

import ../logger

import config

import zippy/ziparchives

type
    Console* = ref object of RootObj


method getBinaryExtension(this: Console): string {.base.} =
    raise newException(Exception, "method not implemented")

method getConsoleName(this: Console): string {.base.} =
    raise newException(Exception, "method not implemented")

method getIconExtension(this: Console): string {.base.} =
    raise newException(Exception, "method not implemented")

method getFileExtensions(this: Console): array[0x02, string] {.base.} =
    raise newException(Exception, "method not implemented")

method publish*(this: Console, cfg: Config): bool {.base locks: "unknown".} =
    raise newException(Exception, "method not implemented")

method getDescription(this: Console, data: seq[string]): string {.base.} =
    return data.join(" • ")

method getBinaryName(this: Console): string {.base.} =
    return fmt("LOVEPotion.{this.getBinaryExtension()}")

method handleFile(this: Console, source: string, dest: string): bool {.base.} =
    try:
        if (not os.fileExists(dest) or os.fileNewer(source, dest)):
            logger.info(formatLog(LogData.HandleFile, source, dest))
            return true
    except Exception as e:
        logger.error(formatLog(LogData.HandleFileError, source, e.msg))

    logger.info(formatLog(LogData.SourceUnchanged, source, dest))
    return false

method clean(this: Console, buildDir: string) {.base.} =
    logger.info(formatLog(LogData.Cleaning))

    let extensions = @[".love", ".nacp", ".smdh"]

    for item in os.walkDir(buildDir):
        let (_, _, fileExt) = os.splitFile(item.path)

        for check in extensions:
            if (check == fileExt):
                logger.info(formatLog(LogData.CleanFile, item.path))
                os.removeFile(item.path)

method convertFiles(this: Console, source: string,
        buildDir: string, convert: bool = false): bool {.base.} =
    for filepath in os.walkDirRec(source, relative = true):
        if (os.isHidden(filepath)):
            continue

        let parent = os.parentDir(filepath)

        let relativePath = (source / filepath)
        let destinationDir = (buildDir / parent)

        let filename = os.extractFilename(filepath)
        var destination = destinationDir / filename

        try:
            os.createDir(destinationDir)

            # Replace the filename extension as needed
            if (convert):
                destination = destinationDir / extension.replace(filename)

            # Check if the file is newer
            if (not this.handleFile(relativePath, destination)):
                continue

            var success: bool = true

            # Handle copy or convert
            if (convert):
                case extension.fromExtension(filepath):
                    of Extension.T3x:
                        success = command.run($Command.Tex3ds, relativePath, destination)
                    of Extension.Bcfnt:
                        success = command.run($Command.MkBcfnt, relativePath, destination)
                    else:
                        os.copyFile(relativePath, destination)
            else:
                os.copyFile(relativePath, destination)

            if (not success):
                return false

        except IOError as e:
            logger.error(formatLog(LogData.HandleFileError, relativePath, e.msg))
            return false

    return true

method checkBinary(this: Console, path: string): tuple[path: string,
        exists: bool] {.base.} =

    let filepath = path / this.getBinaryName()
    return (filepath, os.fileExists(filepath))

method getOutputBinaryName(this: Console, config: Config): string {.base.} =
    var name = config.metadata.name

    if not (os.isValidFilename(name)):
        for invalid in os.invalidFilenameChars:
            let index = name.find(invalid)

            if index != -1:
                delete(name, index .. index)

    return name

method packGameFiles(this: Console, name, source, buildDir: string): bool {.base.} =
    logger.info(formatLog(LogData.PackingGameContent))

    try:
        logger.info(fmt("Zipping {source} to {name}.love"))
        ziparchives.createZipArchive(fmt("{source}/"), buildDir / fmt("{name}.love"))
    except Exception as e:
        logger.error(formatLog(LogData.PackingGameContentError, e.msg))
        return false

    logger.info(formatLog(LogData.PackingGameContentSuccess))

    return true
