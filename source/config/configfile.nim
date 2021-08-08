import os, strutils, sequtils

import parsetoml

let configDir         = getConfigDir()
let CONFIG_DIRECTORY* = normalizedPath(configDir & "/.lovebrew")

type
    ConfigData* = object
        filepath* : string

        # Metadata

        name        : string
        author      : string
        description : string
        version     : string

        # Build Options

        clean         : bool
        targets       : seq[string]
        source        : string
        icon          : string
        binSearchPath : string

        # Output Options

        buildPath : string
        rawData   : bool
        romFS     : string

        confVersion : string


var Config* : ConfigData

proc load*(config : var ConfigData) : bool =
    ## Fill the ConfigData struct

    if config.filepath.isEmptyOrWhitespace():
        return false

    let tomlValueRef = parseToml.parseFile(config.filepath)

    # Metadata

    var field = tomlValueRef["metadata"]

    config.name   = field["name"].getStr("SuperGame")
    config.author = field["author"].getStr("SuperAuthor")

    config.description = field["description"].getStr("Super Awesome Game")
    config.version     = field["version"].getStr("0.1.0")

    ## Build Options

    field = tomlValueRef["build"]

    config.clean   = field["clean"].getBool(false)

    let targets = field["targets"].getElems()
    config.targets = map(targets, proc(x: TomlValueRef) : string = x.getStr())

    config.source = field["source"].getStr("game")
    config.icon   = field["icon"].getStr("icon")

    var binSearchPath = field["binSearchPath"].getStr()

    if binSearchPath.isEmptyOrWhitespace():
        binSearchPath = CONFIG_DIRECTORY

    config.binSearchPath = binSearchPath

    field = tomlValueRef["output"]

    config.buildPath = field["build"].getStr("build")
    config.rawData   = field["rawData"].getBool(false)
    config.romFS = field["romFS"].getStr("game")

    return true

proc getMetadata*(config : ConfigData) : tuple[name, author, description, version : string] =
    return (name: config.name, author: config.author, description: config.description, version: config.version)

proc getBuildOptions*(config : ConfigData) : tuple[clean : bool, source, icon, binSearchPath : string] =
    return (clean: config.clean, source: config.source, icon: config.icon, binSearchPath: config.binSearchPath)

proc getOutputOptions*(config : ConfigData) : tuple[buildPath : string, romFS : string] =
    return (buildPath: config.buildPath, romFS: config.romFS)

proc getTargets*(config : ConfigData) : seq[string] =
    ## Get the Build Targets

    return config.targets

proc getBuildDirectory*(config : ConfigData) : string =
    ## Get the Build Directory (standalone)

    return config.buildPath

proc getSourceDirectory*(config : ConfigData) : string =
    ## Get the Game 'Source Directory' (standalone)

    return config.source

proc shouldOutputRawData*(config : ConfigData) : bool =
    ## Get whether to output converted files only (3DS)

    return config.rawData
