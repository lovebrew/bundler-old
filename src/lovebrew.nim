import os
import rdstdin
import strutils

import client
import config
import assets
import strings
import logger

import cligen
import strformat


proc init() =
    ## Initialize a new config file, if applicable

    if not os.fileExists(config.ConfigFilePath):
        try:
            io.writeFile(config.ConfigFilePath, assets.DefaultConfigFile)
        except IOError as e:
            raiseError(Error.ConfigOverwrite, e.msg)

        return

    var answer: string
    discard rdstdin.readLineFromStdin(strings.ConfigExists, answer)

    if answer.toLower() == "y":
        os.removeFile(config.ConfigFilePath)
        lovebrew.init()

proc build(app_version: string = "2") =
    let configFile = config.init()

    os.createDir(configFile.build.saveDir)
    var successful = true

    for target in configFile.build.targets:
        logger.info(&"Building for target: {target}")
        let (success, filename, content) = client.send_data(target, app_version,
                $configFile.metadata, configFile.build.source)

        if success:
            io.writeFile(&"{configFile.build.saveDir}/{filename}", content)
            echo(&"Build for {target} was successful.")
        else:
            logger.error(content)
            successful = false

    if not successful:
        var message = "Some builds were not successful. Enable logging an re-run."
        if configFile.debug.logging:
            message = &"Some builds were not successful. Please check logs at\n{config.LogFilePath}"

        echo(message)

proc version() =
    ## Show program version and exit

    echo(strings.NimblePkgVersion)

when isMainModule:
    cligen.dispatchMulti([lovebrew.init], [build], [version])
