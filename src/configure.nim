import os
import strutils
import strformat
import regex

import assetsfile
import logger
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

        # Debug
        logging*: bool

var config*: Config

let ConfigFilePath* = os.normalizedPath(os.getCurrentDir() & "/lovebrew.toml")
let ConfigDirectory* = os.normalizedPath(os.getConfigDir() & "/lovebrew")

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

proc loadDebug(conf: var Config, toml: TomlValueRef) =
    conf.logging = toml["logging"].getBool(false)

let compatible = @["0.5.4", "0.5.3", "0.5.2", "0.5.1", "0.5.0"]
proc checkVersion(configVersion: string, outVersion: var string): bool =
    let version_regex = re"# VERSION (.+) #"
    var m: RegexMatch
    let find_version = regex.find(assetsfile.DefaultConfigFile, version_regex, m)

    var version: string
    if find_version:
        version = m.groupFirstCapture(0, assetsfile.DefaultConfigFile)

    for item in compatible:
        if configVersion != item:
            continue

        return true

    outVersion = version
    return false

proc load*(): bool =
    let tomlBuffer = readFile(ConfigFilePath)
    var m: RegexMatch
    let find_version = regex.find(tomlBuffer, re"# VERSION (.+) #", m)

    var compatible: bool
    var configVersion: string

    if find_version:
        configVersion = m.groupFirstCapture(0, tomlBuffer)

    var outVersion: string

    if not configVersion.isEmptyOrWhitespace():
        compatible = checkVersion(configVersion, outVersion)

    if not compatible:
        echo(strings.OutdatedConfg.format(configVersion, outVersion))
        return false

    try:
        let toml = parseFile(ConfigFilePath)

        config.loadMetadata(toml["metadata"])
        config.loadBuild(toml["build"])
        config.loadOutput(toml["output"])

        if "debug" in toml:
            config.loadDebug(toml["debug"])
    except IOError:
        echo(strings.NoConfig)
        return false

    logger.load(fmt"{ConfigDirectory}/lovebrew.log", config.logging)

    return true
