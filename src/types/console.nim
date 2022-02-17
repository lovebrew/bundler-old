import os
import strformat
import strutils

import ../data/strings
import ../logger
import config

import zippy/ziparchives

type
    Console* = ref object of RootObj

proc notImplemented() =
    raise newException(Exception, "method not implemented")

method getBinaryExtension(this: Console): string {.base.} =
    notImplemented()

method getConsoleName(this: Console): string {.base.} =
    notImplemented()

method getIconExtension(this: Console): string {.base.} =
    notImplemented()

method getFileExtensions(this: Console): array[0x02, string] {.base.} =
    notImplemented()

method publish*(this: Console, cfg: Config): bool {.base.} =
    notImplemented()

method getDescription(this: Console, data: seq[string]): string {.base.} =
    return data.join(" • ")

method getBinaryName(this: Console): string {.base.} =
    return fmt("LOVEPotion.{this.getBinaryExtension()}")

method handleFile(this: Console, source: string, dest: string): bool {.base.} =
    try:
        if not os.fileExists(dest) or fileNewer(source, dest):
            logger.info(formatLog(LogData.CopyConvertWhat, source, dest))
            return true
    except Exception as e:
        logger.error(formatLog(LogData.CopyConvertError, source, e.msg))

    logger.info(formatLog(LogData.SourceUnchanged, source))
    return false

method packGameFiles(this: Console, name, source,
        buildDir: string): bool {.base.} =
    try:
        ziparchives.createZipArchive(fmt("{source}/"), buildDir / fmt("{name}.love"))
    except Exception as e:
        logger.error(formatLog(LogData.PackingGameContentError, e.msg))
        return false

    return true
