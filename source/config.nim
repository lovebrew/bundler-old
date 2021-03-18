import os, tables

import parsetoml

import paths, prompts

let CONFIG_FILE = getPath("CONFIG_FILE")
var configTable : TomlValueRef

proc loadConfigFile*() : bool =
    ## Build the project for the console(s)
    if not CONFIG_FILE.fileExists():
        showPrompt("CONFIG_NOT_FOUND")
        return false

    configTable = CONFIG_FILE.parseFile()

    return true

proc getMetadata*() : TomlValueRef =
    return configTable["metadata"]

proc getMetadataValue*(key : string) : string =
    let sectionRef = configTable["metadata"]
    return sectionRef[key].getStr()

proc getBuildValue*(key : string) : TomlValueRef =
    let sectionRef = configTable["build"]
    return sectionRef[key]
