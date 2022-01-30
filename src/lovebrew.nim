import os
import rdstdin
import strutils
import strformat

import environment
import data/strings
import data/assets
import types/config
import enums/target
import types/console
import types/ctr

import cligen

let FirstRunFile = config.ConfigDirectory / ".first_run"

proc init() =
    ## Initializes a new config file

    if not os.fileExists(config.ConfigFilePath):
        try:
            io.writeFile(config.ConfigFilePath, assets.DefaultConfigFile)
        except IOError as e:
            echo(fmt("{strings.ConfigOverwriteFailed} {e.msg}"))
        finally:
            return

    var answer: string
    discard rdstdin.readLineFromStdin(strings.ConfigExists, line = answer)

    if answer.toLower() == "y":
        os.removeFile(config.ConfigFilePath)
        lovebrew.init()

proc build() =
    ## Build the project for the current targets in the config file

    var configData = Config()
    if not configData.initialize():
        return

    if not environment.checkToolchainInstall(configData.getTargets()):
        return

    os.createDir(configData.output.buildDir)

    for target in configData.build.targets:
        let console = Ctr()

        console.initialize(configData)
        if console.publish():
            echo(strings.BuildSuccess.format(console.getConsoleName()))
        else:
            echo(strings.BuildFailure.format(console.getConsoleName()))

proc clean() =
    ## Clean the set output directory

    return

proc version() =
    ## Show program version and exit

    echo(strings.NimblePkgVersion)

when defined(gcc) and defined(windows):
    {.link: "res/icon.o".}

when isMainModule:
    if not fileExists(FirstRunFile):
        os.createDir(ConfigDirectory)
        writeFile(FirstRunFile, "")

        echo(FirstRun)
        quit(0)

    try:
        dispatchMulti([init], [build], [clean], [version])
    except Exception as e:
        echo(e.msg)
