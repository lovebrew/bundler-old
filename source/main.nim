import system
import strformat, strutils
import sequtils
import os

import cligen

import assets, paths, prompts
import config

import classes/hac
import classes/ctr

let APP_NAME = "LÖVEBrew"
let VERSION = "0.4.0"

let FIRST_RUN_FILE = getPath("FIRST_RUN_FILE")

proc init() =
    ## Initializes a new config file

    # Check that lovebrew.toml doesn't already exist
    if getPath("CONFIG_FILE").fileExists():
        write(stdout, "Config file already exists. Overwrite? [y/N]: ")
        let answer = readLine(stdin).toLower()

        if answer.isEmptyOrWhitespace() or answer == "n" or answer != "y":
            echo("Config file was not overwritten.")
            return
        else:
            echo("Config file was overwritten successfully.")

    # Initialize a new lovebrew.toml file in the current directory
    let fileData = getAsset("lovebrew.toml")
    getPath("CONFIG_FILE").writeFile(fileData)

proc clean() =
    ## Clean the set output directory

    if not loadConfigFile():
        quit(-1)

    try:
        let buildDirectory = getOutputValue("build").getStr()
        buildDirectory.removeDir()
    except OSError:
        echo "Failed to clean the build directory."

proc checkDevkitProTools() : bool =
    ## Check if the proper tools are installed

    # Check for environment variable DEVKITPRO
    if not existsEnv("DEVKITPRO"):
        showPrompt("DEVKITPRO")
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

    if not loadConfigFile():
        quit(-1)

    let targets = config.getBuildValue("targets").getElems()
    let metadata = config.getMetadata()

    template makeConsoleChild(child : type) : untyped =
        child(name: metadata["name"].getStr(), author: metadata["author"].getStr(),
              description: metadata["description"].getStr(), version: metadata["version"].getStr())

    # Get the source directory
    let source = config.getBuildValue("source").getStr()
    if source.isEmptyOrWhitespace():
        echo("Cannot compile. Source directory is empty in lovebrew.toml!")
        return

    if len(targets) == 0:
        echo("Cannot compile. Targets not specified in lovebrew.toml!")
        return

    for element in targets:
        var console =
            if element.getStr() == "switch":
                HAC.makeConsoleChild()
            elif element.getStr() == "3ds":
                CTR.makeConsoleChild()
            else:
                continue

        if console.publish(source):
            echo(fmt("Build for {console.getName()} was successful. Please check '{console.getBuildDirectory()}' for your files."))
        else:
            echo(fmt("Build for {console.getName()} failed."))

proc version() =
    ## Show version info and exit
    echo(fmt("{APP_NAME} {VERSION}"))

when defined(gcc) and defined(windows):
    {.link: "res/icon.o"}

if not FIRST_RUN_FILE.fileExists():
    ## Show the first run dialog if necessary
    showPrompt("FIRST_RUN")

    createDir(getConfigDir() & "/.lovebrew")
    FIRST_RUN_FILE.writeFile("")

    quit(0)

dispatchMulti([init], [build], [clean], [version])
