import system
import strformat, strutils
import sequtils
import os

import cligen

import assets, prompts

import classes/hac
import classes/ctr

import config/parsecfg
import config/configfile

let APP_NAME = "LÖVEBrew"
let VERSION = "0.4.0"

proc init() =
    ## Initializes a new config file

    # Check that lovebrew.toml doesn't already exist
    if CONFIG_FILE.fileExists():
        write(stdout, "Config file already exists. Overwrite? [y/N]: ")
        let answer = readLine(stdin).toLower()

        if answer.isEmptyOrWhitespace() or answer == "n" or answer != "y":
            echo("Config file was not overwritten.")
            return
        else:
            echo("Config file was overwritten successfully.")

    # Initialize a new lovebrew.toml file in the current directory
    let fileData = getAsset("lovebrew.toml")
    CONFIG_FILE.writeFile(fileData)

proc clean() =
    ## Clean the set output directory

    if not parsecfg.loadConfigFile():
        quit(-1)

    try:
        Config.getBuildDirectory().removeDir()
    except OSError:
        echo "Failed to clean the build directory."

proc checkDevkitProTools() : bool =
    ## Check if the proper tools are installed

    # Check for environment variable DEVKITPRO
    if not existsEnv("DEVKITPRO"):
        DEVKITPRO.show()
        return false

    ## Check for 3DS and Switch requirements
    ##
    ## 3dsxtool and smdhtool are provided by 3dstools
    ## so we only need to check for one of them
    ## tex3ds and mkbcfnt are provided by tex3ds
    ##
    ## nacptool and elf2nro are provided by switch-tools
    ## so we only need to check for one of them

    let find3DSBinaries = @["3dsxtool", "tex3ds"]
    let findSwitchBinaries = @["nacptool"]

    return find3DSBinaries.anyIt(it.findBinary) or findSwitchBinaries.anyIt(it.findBinary)

proc build() =
    ## Build the project for the current targets in the config file

    if not checkDevkitProTools():
        quit(-1)

    if not parsecfg.loadConfigFile():
        quit(-1)

    let targets = Config.getTargets()

    if len(targets) == 0:
        ZERO_TARGETS.show()
        return

    let source = Config.getSourceDirectory()
    if source.isEmptyOrWhitespace() or not source.dirExists():
        NO_SOURCE.show()
        return

    for element in targets:
        var console : Console

        case element:
            of "switch":
                makeConsoleChild(HAC)
            of "3ds":
                makeConsoleChild(CTR)
            else:
                continue

        initVariables()
        preBuildCleanup()

        if console.publish(source):
            BUILD_SUCCESS.showFormatted(console.getName(), Config.getBuildDirectory())

proc version() =
    ## Show version info and exit
    echo(fmt("{APP_NAME} {VERSION}"))

when defined(gcc) and defined(windows):
    {.link: "res/icon.o"}

if not FIRST_RUN_FILE.fileExists():
    ## Show the first run dialog if necessary
    FIRST_RUN.show()

    createDir(getConfigDir() & "/.lovebrew")
    FIRST_RUN_FILE.writeFile("")

    quit(0)

dispatchMulti([init], [build], [clean], [version])
