import os
import rdstdin
import strutils

import setup
import data/strings
import data/assets
import types/config
import enums/target

import types/ctr

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

proc build() =
    ## Build the project for the current targets in the config file

    let configFile = config.initialize()

    if not setup.check(configFile.build.targets):
        return

    os.createDir(configFile.output.buildDir)

    for target in configFile.build.targets:
        let console = case target:
            of TARGET_CTR:
                Ctr()
            of TARGET_HAC:
                nil

        if not console.isNil():
            if console.publish(configFile):
                displayBuildStatus(BuildStatus.Success, console.getConsoleName())
            else:
                displayBuildStatus(BuildStatus.Failure, console.getConsoleName())

proc clean() =
    ## Clean the output directory

    let configFile = config.initialize()
    os.removeDir(configFile.output.buildDir)

proc version() =
    ## Show program version and exit

    echo(strings.NimblePkgVersion)

when defined(gcc) and defined(windows):
    {.link: "res/icon/icon.o".}

when isMainModule:
    try:
        setup.initialize()
        dispatchMulti([init], [build], [clean], [version])
    except Exception as e:
        echo(e.msg)
