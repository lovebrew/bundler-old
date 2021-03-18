import system
import strformat
import sequtils
import os

import cligen
import parsetoml

import assets, paths, prompts

import classes/hac
import classes/ctr

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
    if not checkDevkitProTools():
        quit(-1)

    ## Build the project for the console(s)
    if not CONFIG_FILE.fileExists():
        showPrompt("CONFIG_NOT_FOUND")
        return

    let config = parseFile(CONFIG_FILE)

    let targets = config["build"]["targets"].getElems()
    let meta = config["metadata"]

    template makeConsoleChild(child: type): untyped =
        child(name: meta.getStr("name"), author: meta.getStr("author"),
              description: meta.getStr("description"), version: meta.getStr("version"))

    for element in targets:
        var console =
          if element.stringVal == "switch":
            HAC.makeConsoleChild()
          else:
            CTR.makeConsoleChild()

        console.compile()

proc version() =
    ## Show version info and exit
    echo(fmt("{APP_NAME} {VERSION}"))

if not FIRST_RUN_FILE.fileExists():
    ## Show the first run dialog if necessary
    showPrompt("FIRST_RUN")
    FIRST_RUN_FILE.writeFile("")

    quit(0)

dispatchMulti([ init,    cmdName = "init",    "Create a new lovebrew project"    ],
              [ clean,   cmdName = "clean",   "Clean the output directory"       ],
              [ build,   cmdName = "build",   "Build the game for the target(s)" ],
              [ version, cmdName = "version", "Show version info and exit"       ])
