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

let ConfigFilePath* = os.normalizedPath(os.getCurrentDir() / "lovebrew.toml")

let ConfigDirectory = os.normalizedPath(os.getConfigDir() / "lovebrew")
let LogFilePath = os.normalizedPath(ConfigDirectory / "lovebrew.log")

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
    if not os.fileExists(ConfigFilePath):
        raiseError(Error.NoConfig)

    var contents = readFile(ConfigFilePath)
    var config: Config

    try:
        config = Toml.decode(contents, Config)
        checkCompatible(config.debug.version)

        config.build.targets = config.build.targets.mapIt(FriendlyNameMappings.getOrDefault(it, it))
        logger.init(LogFilePath, config.debug.logging)

        return config
    except TomlError as e:
        raiseError(Error.InvalidConfig, e.msg)
