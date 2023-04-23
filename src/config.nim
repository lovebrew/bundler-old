import os
import sequtils
import strutils
import tables

import logger
import strings


import toml_serialization

# --------------------------------------- #

type
    Metadata = object
        title*: string
        author*: string
        description*: string
        version*: string
        icon*: string

type
    Build = object
        clean*: bool
        targets*: seq[string]
        source*: string
        saveDir*: string

type
    Debug = object
        logging*: bool
        version: string

type
    Config* = object
        metadata*: Metadata
        build*: Build
        debug*: Debug

# ----------------------------------------------------------------------- #

const CompatibleVersions = @[strings.NimblePkgVersion]

let configFilePath* = os.normalizedPath(os.getCurrentDir() / "lovebrew.toml")

proc checkCompatible(configValue: string) {.raises: [Exception].} =
    if not CompatibleVersions.anyIt(it == configValue):
        raiseError(Error.OutdatedConfig, configValue, strings.NimblePkgVersion)

proc `$`*(data: Metadata): Table[string, string] =
    result = initTable[string, string]()

    for field, value in data.fieldPairs():
        result[$field] = $value

    return result

let FriendlyNameMappings = {
    "3ds": "ctr",
    "switch": "hac",
    "wiiu": "cafe"
}.toTable()

proc init*(): Config =
    if not os.fileExists(configFilePath):
        raiseError(Error.NoConfig)

    var contents = readFile(configFilePath)
    var config: Config

    try:
        config = Toml.decode(contents, Config)

        config.build.targets.applyIt(FriendlyNameMappings[it])

        return config
    except TomlError as e:
        raiseError(Error.InvalidConfig)
