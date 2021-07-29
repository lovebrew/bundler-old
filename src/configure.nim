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
        outputName*: string

var config*: Config

let ConfigFilePath* = os.normalizedPath(os.getCurrentDir() & "/lovebrew.toml")
let ConfigDirectory* = os.normalizedPath(os.getConfigDir() & "/lovebrew")

var TargetsTable: Table[string, Target]

TargetsTable["3ds"] = Target_Ctr
TargetsTable["switch"] = Target_Hac

proc loadMetadata(conf: var Config, toml: TomlValueRef) =
    conf.name = toml["name"].getStr()
    conf.author = toml["author"].getStr()

    conf.description = toml["description"].getStr()
    conf.version = toml["version"].getStr()

proc loadBuild(conf: var Config, toml: TomlValueRef) =
    conf.clean = toml["clean"].getBool()

    let targets = toml["targets"].getElems()

    if len(targets) == 0:
        raise newException(Exception, strings.NoTargets)

    for target in targets:
        conf.targets.add(TargetsTable[target.getStr()])

    conf.source = toml["source"].getStr()

    conf.icon = toml["icon"].getStr()

    var searchPath = toml["binSearchPath"].getStr()
    if isEmptyOrWhitespace(searchPath):
        searchPath = ConfigDirectory

    conf.binSearchPath = searchPath

proc loadOutput(conf: var Config, toml: TomlValueRef) =
    conf.build = toml["build"].getStr()
    conf.rawData = toml["rawData"].getBool()
    conf.outputName = toml["outputName"].getStr()

proc load*(): bool =
    try:
        let toml = parseFile(ConfigFilePath)

        config.loadMetadata(toml["metadata"])
        config.loadBuild(toml["build"])
        config.loadOutput(toml["output"])
    except Exception:
        return false

    return true
