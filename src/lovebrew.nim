import os
import rdstdin
import strutils

import client
import config
import assets
import strings

import cligen

proc init() =
    ## Initialize a new config file, if applicable

    if not os.fileExists(config.configFilePath):
        try:
            io.writeFile(config.configFilePath, assets.DefaultConfigFile)
        except IOError as e:
            raiseError(Error.ConfigOverwrite, e.msg)

        return

    var answer: string
    discard rdstdin.readLineFromStdin(strings.ConfigExists, answer)

    if answer.toLower() == "y":
        os.removeFile(config.configFilePath)
        lovebrew.init()

proc build(app_version: string = "2") =
    let configFile = config.init()

    os.createDir(configFile.build.saveDir)

    for target in configFile.build.targets:
        client.send_data(target, app_version, $configFile.metadata, configFile.build.source)

proc version() =
    ## Show program version and exit

    echo(strings.NimblePkgVersion)

when isMainModule:
    cligen.dispatchMulti([lovebrew.init], [build], [version])
