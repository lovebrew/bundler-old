import os
import rdstdin

import cligen; include cligen/mergeCfgEnv

const version = staticRead("../lovebrew.nimble").fromNimble("version")
clCfg.version = version

import assetsfile
import configure
import environment

import types/ctr
import types/target

import strings

import tables

proc init() =
    ## Initializes a new config file

    if not os.fileExists(configure.ConfigFilePath):
        writeFile(configure.ConfigFilePath, assetsfile.DefaultConfigFile)
        return

    var answer: string
    discard readLineFromStdin(strings.ConfigExists, line = answer)

    if answer.toLower() == "y":
        try:
            writeFile(configure.ConfigFilePath, assetsfile.DefaultConfigFile)
        except Exception as e:
            echo(strings.ConfigOverwriteFailed & " " & e.msg)

proc build() =
    ## Build the project for the current targets in the config file

    if not configure.load():
        raise newException(Exception, strings.NoConfig)

    if not environment.checkToolchainInstall():
        return

    var TargetClasses: Table[Target, Console]

    TargetClasses[Target_Ctr] = Ctr()
    # TargetClasses[Target.Hac] = hac.Hac()

    os.createDir(config.build)

    for target in config.targets:
        TargetClasses[target].publish(config.source)

proc clean() =
    ## Clean the set output directory

    if not configure.load():
        raise newException(Exception, strings.NoConfig)

    removeDir(config.build)

when defined(gcc) and defined(windows):
    {.link: "res/icon.o"}

when isMainModule:
    try:
        dispatchMulti([init], [build], [clean])
    except Exception as e:
        echo(e.msg)