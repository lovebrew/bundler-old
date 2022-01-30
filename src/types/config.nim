import os
import strutils

import ../enums/target
import ../environment
import ../logger
import ../data/strings

import parsetoml
import regex

type
    Metadata = object
        name*: string
        author*: string
        description*: string
        version*: string

type
    Build = object
        clean*: bool
        targets*: seq[Target]
        source*: string
        icon*: string
        searchPath*: string

type
    Output = object
        buildDir*: string
        asRaw*: bool
        gameDir*: string

type
    Debug = object
        logging*: bool

# --------------------------------------- #

let ConfigFilePath* = os.normalizedPath(os.getCurrentDir() / "lovebrew.toml")
let ConfigDirectory* = os.normalizedPath(os.getConfigDir() / "lovebrew")

type
    Config* = object
        metadata*: Metadata
        build*: Build
        output*: Output
        debug*: Debug

proc getTargets*(cfg: Config): seq[Target] =
    return cfg.build.targets

proc checkCompatibility(fileBuffer: string): bool =
    var match: RegexMatch
    let findVersion = regex.find(fileBuffer, re"# VERSION (.+) #", match)

    if findVersion:
        let configVersion = match.groupFirstCapture(0, fileBuffer)

        var outVersion: string
        if not environment.isCompatible(configVersion, outVersion):
            echo(strings.OutdatedConfg.format(configVersion, outVersion))
            return false

    return true

proc fetchMetdata(metadata: var Metadata, section: TomlValueRef) =
    metadata.name = section["name"].getStr()
    metadata.author = section["author"].getStr()
    metadata.description = section["description"].getStr()
    metadata.version = section["version"].getStr()

proc fetchBuild(build: var Build, section: TomlValueRef) =
    build.clean = section["clean"].getBool()

    let targets = section["targets"].getElems()

    if len(targets) == 0:
        raise newException(Exception, strings.NoTargets)
    else:
        for targetValue in targets:
            let targetName = targetValue.getStr()
            if target.isValid(targetName) and len(build.targets) <= 2:
                build.targets.insert(target.asEnum(targetName))

    build.source = section["source"].getStr()
    build.icon = section["icon"].getStr()

    build.searchPath = section["binSearchPath"].getStr()
    if isEmptyOrWhitespace(build.searchPath):
        build.searchPath = ConfigDirectory

proc fetchOutput(output: var Output, section: TomlValueRef) =
    output.buildDir = section["buildDir"].getStr()
    output.asRaw = section["rawData"].getBool()
    output.gameDir = section["gameDir"].getStr()

proc initialize*(cfg: var Config): bool =
    try:
        let fileBuffer = io.readFile(config.ConfigFilePath)

        if not config.checkCompatibility(fileBuffer):
            return false
    except IOError:
        echo(strings.NoConfig)
        return false

    try:
        let tomlFile = parsetoml.parseFile(ConfigFilePath)

        fetchMetdata(cfg.metadata, tomlFile["metadata"])
        fetchBuild(cfg.build, tomlFile["build"])
        fetchOutput(cfg.output, tomlFile["output"])

        if "debug" in tomlFile:
            cfg.debug.logging = tomlFile["debug"]["logging"].getBool()

    except IOError:
        echo(strings.NoConfig)
        return false

    logger.load(ConfigDirectory / "lovebrew.log", cfg.debug.logging)

    return true
