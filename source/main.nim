import system
import strformat
import osproc
import os

import cligen

import assets, paths, prompts
import "classes/hac"

let APP_NAME = "LÖVEBrew"
let APP_DESCRIPTION = "LÖVE Potion Game Distribution Helper"
let VERSION = "4.0.0"

proc init() =
    ## Initialize a new lovebrew.toml file in the current directory
    let fileData = getAsset("lovebrew.toml")
    writeFile(getCurrentDir() & "lovebrew.toml", fileData)

proc clean() =
    ## Clean the set output directory
    quit(0)

proc build() =
    ## Build the project for the console(s)
    quit(0)

proc version() =
    ## Show version info and exit
    echo(fmt"{APP_NAME} {VERSION}")

proc checkDevkitProTools() : bool =
    ## Check if the proper tools are installed
    return true

if not fileExists(getConfigPath("FIRST_RUN_FILE")):
    ## Show the first run dialog if necessary
    showPrompt("FIRST_RUN")
    writeFile(getConfigPath("FIRST_RUN_FILE"), "")

    quit(0)

dispatchMulti([init,    cmdName = "init",    "Create a new lovebrew project"],
              [clean,   cmdName = "clean",   "Clean the output directory"],
              [build,   cmdName = "build",   "Build the game for the target(s)"],
              [version, cmdName = "version", "Show version info and exit"])
