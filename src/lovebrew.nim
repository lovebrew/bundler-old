import os
import rdstdin
import strutils
import tables

import setup
import data/strings
import data/assets
import types/config
import enums/target

import logger

import types/ctr
import types/hac

import cligen

proc init() =
    ## Initializes a new config file

    if not os.fileExists(config.ConfigFilePath):
        try:
            io.writeFile(config.ConfigFilePath, assets.DefaultConfigFile)
        except IOError as e:
            raiseError(Error.ConfigOverwrite, e.msg)
        finally:
            return

    var answer: string
    discard rdstdin.readLineFromStdin(strings.ConfigExists, line = answer)

    if answer.toLower() == "y":
        os.removeFile(config.ConfigFilePath)
        lovebrew.init()

proc compile(item: auto, configFile: Config) =
    if item.publish(configFile):
        displayBuildStatus(BuildStatus.Success, item.getConsoleName())
    else:
        displayBuildStatus(BuildStatus.Failure, item.getConsoleName())

proc build() =
    ## Build the project for the current targets in the config file

    let configFile = config.initialize()

    if not setup.check(configFile.build.targets):
        return

    os.createDir(configFile.output.buildDir)

    for target in configFile.build.targets:
        if target == TARGET_CTR:
            compile(Ctr(), configFile)
        elif target == TARGET_HAC:
            compile(Hac(), configFile)

proc clean() =
    ## Clean the output directory
    logger.info(formatLog(LogData.Cleaning))

    let configFile = config.initialize()
    os.removeDir(configFile.output.buildDir)

proc version() =
    ## Show program version and exit

    echo(strings.NimblePkgVersion)

when defined(gcc) and defined(windows):
    {.link: "res/icon/icon.o".}

when isMainModule:
    setup.initialize()
    dispatchMulti([init], [build], [clean], [version])
