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
    ## Check that lovebrew.toml doesn't already exist
    if getPath("CONFIG_FILE").fileExists():
        write(stdout, "Config file already exists. Overwrite? [y/N]: ")
        let answer = readLine(stdin).toLower()

        if answer.isEmptyOrWhitespace() or answer == "n" or answer != "y":
            echo("Config file was not overwritten.")
            return
        else:
            echo("Config file was overwritten successfully.")

    ## Initialize a new lovebrew.toml file in the current directory
    let fileData = getAsset("lovebrew.toml")
    getPath("CONFIG_FILE").writeFile(fileData)

proc clean() =
    ## Clean the set output directory
    try:
        getOutputValue("build").removeDir()
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
    if not checkDevkitProTools():
        quit(-1)

    if not loadConfigFile():
        quit(-1)

    let targets = config.getBuildValue("targets").getElems()
    let metadata = config.getMetadata()

    template makeConsoleChild(child : type) : untyped =
        child(name: metadata.getStr("name"), author: metadata.getStr("author"),
              description: metadata.getStr("description"), version: metadata.getStr("version"))

    ## Create the build directory
    createDir(getOutputValue("build"))

    ## Get the source directory
    let source = config.getBuildValue("source").getStr()

    for element in targets:
        var console =
            if element.getStr() == "switch":
                HAC.makeConsoleChild()
            else:
                CTR.makeConsoleChild()

        console.compile(source)

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
