import os
import strutils
import strformat
import osproc

import ../logger
import config

import iface
import zippy/ziparchives

const BinaryExtensions = @[".3dsx", ".nro"]
const MetadataExtensions = @[".smdh", ".nacp"]

type
    ConsoleBase* = ref object of RootObj
        config*: Config

iface(*Console):
    proc getBinaryExtension(): string
    proc getConsoleName(): string
    proc getIconExtension(): string
    proc publish(): bool

method initialize*(this: ConsoleBase, config: Config) {.base.} =
    this.config = config

method getDescription*(this: ConsoleBase): string {.base.} =
    return this.config.metadata.description

proc handleFile*(source: string, dest: string): bool =
    try:
        if not os.fileExists(dest) or fileNewer(source, dest):
            logger.info(fmt("Copying/converting file {source} to {dest}."))
            return true
    except Exception as e:
        logger.error(fmt("Something went wrong: {e.msg} ({dest})"))

    logger.info(fmt("File source {source} for {dest} is not newer. Skipping."))
    return false

proc execute*(command: string): bool =
    let execResult = osproc.execCmdEx(command)

    if execResult.exitCode != 0:
        logger.warning(fmt("Command Error: {command} -> {execResult.output}"))
        return false

    return true

proc getBinaryName*(this: Console): string =
    return fmt("LOVEPotion.{this.getBinaryExtension()}")

proc getBinaryPath*(this: Console): string =
    return this.to(ConsoleBase).config.build.searchPath / this.getBinaryName()

proc checkBinaryExists*(this: Console): bool =
    return os.fileExists(this.getBinaryPath())
