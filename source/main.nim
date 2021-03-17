import system
import strformat
import sequtils
import os

import cligen
import parsetoml

import assets, paths, prompts
import classes/hac

let APP_NAME = "LÖVEBrew"
let APP_DESCRIPTION = "LÖVE Potion Game Distribution Helper"
let VERSION = "4.0.0"

let CONFIG_FILE = getConfigPath("CONFIG_FILE")
let FIRST_RUN_FILE = getConfigPath("FIRST_RUN_FILE")

proc init() =
    ## Initialize a new lovebrew.toml file in the current directory
    let fileData = getAsset("lovebrew.toml")
    CONFIG_FILE.writeFile(fileData)

proc clean() =
    ## Clean the set output directory
    quit(0)

proc build() =
    ## Build the project for the console(s)

    if not CONFIG_FILE.fileExists():
        showPrompt("CONFIG_NOT_FOUND")
        return

    let config = parseFile(CONFIG_FILE)
    echo config

    var console = HAC(app_name: "Test", author: "someone", description: "aaaaaa", version: "0.1.0")

proc version() =
    ## Show version info and exit
    echo(fmt("{APP_NAME} {VERSION}"))

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

    let findBinaries = @["3dstool", "tex3ds", "nacptool"]

    if findBinaries.anyIt(not it.findBinary):
        return false

    return true

if not FIRST_RUN_FILE.fileExists():
    ## Show the first run dialog if necessary
    showPrompt("FIRST_RUN")
    FIRST_RUN_FILE.writeFile("")

    quit(0)

if not checkDevkitProTools():
    quit(-1)

dispatchMulti([ init,    cmdName = "init",    "Create a new lovebrew project"    ],
              [ clean,   cmdName = "clean",   "Clean the output directory"       ],
              [ build,   cmdName = "build",   "Build the game for the target(s)" ],
              [ version, cmdName = "version", "Show version info and exit"       ])
