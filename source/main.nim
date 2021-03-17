import system
import strformat
import strutils
import os

import cligen
import parsetoml

import assets, paths, prompts
import "classes/hac"

let APP_NAME = "LÖVEBrew"
let APP_DESCRIPTION = "LÖVE Potion Game Distribution Helper"
let VERSION = "4.0.0"

proc init() =
    ## Initialize a new lovebrew.toml file in the current directory
    let fileData = getAsset("lovebrew.toml")
    writeFile(getConfigPath("CONFIG_FILE"), fileData)

proc clean() =
    ## Clean the set output directory
    quit(0)

proc build() =
    ## Build the project for the console(s)
    if not fileExists(getConfigPath("CONFIG_FILE")):
        showPrompt("CONFIG_NOT_FOUND")
        return

    let config = parseFile(getConfigPath("CONFIG_FILE"))

    var console = HAC(app_name: "Test", author: "someone", description: "aaaaaa", version: "0.1.0")
    echo console.get_icon()

proc version() =
    ## Show version info and exit
    echo(fmt("{APP_NAME} {VERSION}"))

proc checkDevkitProTools() : bool =
    ## Check if the proper tools are installed

    # Check for environment variable DEVKITPRO
    if not existsEnv("DEVKITPRO"):
        showPrompt("DEVKITPRO")
        return false

    ## Check for 3DS requirements
    ## 3dsxtool and smdhtool are provided by 3dstools
    ## so we only need to check for one of them
    ## tex3ds and mkbcfnt are provided by tex3ds

    # Check for 3dsxtool
    if findExe("3dsxtool").isEmptyOrWhitespace():
        showPrompt("3DSXTOOL")
        return false
    else:
        echo("\n" & "3dsxtool was found, but not in your PATH environment. Please add it.")

    # Check for tex3ds
    if findExe("tex3ds").isEmptyOrWhitespace():
        showPrompt("TEX3DS")
        return false
    else:
        echo("\n" & "tex3ds was found, but not in your PATH environment. Please add it.")

    ## Check for Switch requirements
    ## nacptool and elf2nro are provided by switch-tools
    ## so we only need to check for one of them

    # Check for nacptool
    if findExe("nacptool").isEmptyOrWhitespace():
        showPrompt("NACPTOOL")
        return false
    else:
        echo("\n" & "nacptool was found, but not in your PATH environment. Please add it.")

    return true

if not fileExists(getConfigPath("FIRST_RUN_FILE")):
    ## Show the first run dialog if necessary
    showPrompt("FIRST_RUN")
    writeFile(getConfigPath("FIRST_RUN_FILE"), "")

    quit(0)

if not checkDevkitProTools():
    quit(-1)

dispatchMulti([init,    cmdName = "init",    "Create a new lovebrew project"],
              [clean,   cmdName = "clean",   "Clean the output directory"],
              [build,   cmdName = "build",   "Build the game for the target(s)"],
              [version, cmdName = "version", "Show version info and exit"])
