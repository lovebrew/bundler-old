import os
import strutils

import strings
import types/target

import parsetoml

type
    Config = object
        # Metadata
        name*: string
        author*: string
        description*: string
        version*: string

        # Build
        clean*: bool
        targets*: seq[Target]
        source*: string
        icon*: string
        binSearchPath*: string

        # Output
        build*: string
        rawData*: bool
        romFS*: string

var config*: Config

let ConfigFilePath* = os.normalizedPath(getCurrentDir() & "/lovebrew.toml")
let ConfigDirectory* = os.normalizedPath(getConfigDir() & "/lovebrew")

var TargetsTable: Table[string, Target]

TargetsTable["3ds"] = Target_Ctr
TargetsTable["switch"] = Target_Hac

proc loadMetadata(conf: var Config, toml: TomlValueRef) =
    conf.name = toml["name"].getStr("SuperGame")
    conf.author = toml["author"].getStr("SuperAuthor")

    conf.description = toml["description"].getStr("SuperDescription")
    conf.version = toml["version"].getStr("0.1.0")

proc loadBuild(conf: var Config, toml: TomlValueRef) =
    conf.clean = toml["clean"].getBool(false)

    let targets = toml["targets"].getElems()

    if len(targets) == 0:
        raise newException(Exception, strings.NoTargets)

    for target in targets:
        conf.targets.add(TargetsTable[target.getStr()])

    conf.source = toml["source"].getStr("game")

    conf.icon = toml["icon"].getStr()

    var searchPath = toml["binSearchPath"].getStr()
    if isEmptyOrWhitespace(searchPath):
        searchPath = ConfigDirectory

    conf.binSearchPath = searchPath

proc loadOutput(conf: var Config, toml: TomlValueRef) =
    conf.build = toml["build"].getStr("build")
    conf.rawData = toml["rawData"].getBool(false)
    conf.romFS = toml["romFS"].getStr("game")

proc load*(): bool =
    try:
        let toml = parseFile(ConfigFilePath)

        config.loadMetadata(toml["metadata"])
        config.loadBuild(toml["build"])
        config.loadOutput(toml["output"])
    except Exception:
        return false

    return true
