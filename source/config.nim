import os, tables, strutils

import parsetoml
export parsetoml

import paths, prompts

let CONFIG_FILE = getPath("CONFIG_FILE")
var configTable : TomlValueRef

var ignoreList* = @[".git", ".vscode"]

let configDir = getConfigDir()
var elfPath* = normalizedPath(configDir & "/.lovebrew")

proc loadConfigFile*() : bool =
    ## Build the project for the console(s)
    if not CONFIG_FILE.fileExists():
        showPrompt("CONFIG_NOT_FOUND")
        return false

    configTable = CONFIG_FILE.parseFile()

    try:
        if not configTable["build"]["elfBinary"].getStr().isEmptyOrWhitespace():
            elfPath = configTable["build"]["elfBinary"].getStr()

        return true
    except Exception:
        showPrompt("BAD_CONFIG")

proc getMetadata*() : TomlValueRef =
    return configTable["metadata"]

proc getMetadataValue*(key : string) : string =
    let sectionRef = configTable["metadata"]
    return sectionRef[key].getStr()

proc getBuildValue*(key : string) : TomlValueRef =
    let sectionRef = configTable["build"]
    return sectionRef[key]

proc getOutputValue*(key : string) : TomlValueRef =
    let sectionRef = configTable["output"]
    return sectionRef[key]
