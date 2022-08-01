import os
import strutils
import typetraits
import macros, sequtils

import ../enums/target
import ../logger
import ../data/strings

import parsetoml

# --------------------------------------- #

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
        noBinary*: bool
        gameDir*: string

type
    Debug = object
        logging*: bool
        version: string

# --------------------------------------- #

let ConfigFilePath* = os.normalizedPath(os.getCurrentDir() / "lovebrew.toml")
let ConfigDirectory* = os.normalizedPath(os.getConfigDir() / "lovebrew")
let FirstRunFile* = config.ConfigDirectory / ".first_run"

let LogFilePath = os.normalizedPath(ConfigDirectory / "lovebrew.log")

type
    Config* = object
        metadata*: Metadata
        build*: Build
        output*: Output
        debug*: Debug

macro parseFields(tomlField: TomlValueRef, config: typed): untyped =
    result = newStmtList()
    var configType = config.getType

    case configType.kind:
    of nnkObjectTy:
        for field in configType[2]:
            var
                name = field.strVal
                configField = nnkDotExpr.newTree(config, field)
                fieldType = field.getType
            case fieldType.kind:
            of nnkObjectTy:
                result.add quote do:
                    parseFields(`tomlField`[`name`], `configField`)
            of nnkSym:
                case fieldType.strVal:
                of "string":
                    result.add quote do:
                        `configField` = `tomlField`[`name`].getStr()
                of "int":
                    result.add quote do:
                        `configField` = `tomlField`[`name`].getInt()
                of "bool":
                    result.add quote do:
                        `configField` = `tomlField`[`name`].getBool()
                else: assert false, "Unknown field type: " & fieldType.strVal
            of nnkBracketExpr:
                assert(fieldType[0].kind == nnkSym and fieldType[0].strVal ==
                        "seq", "Unknown type for bracket expr: " & fieldType[0].strVal)
                result.add quote do:
                    parseFields(`tomlField`[`name`], `configField`)
            else:
                continue
    of nnkBracketExpr:
        var fieldType = configType[1].getType
        case fieldType.kind:
        of nnkSym:
            case fieldType.strVal:
                of "string":
                    result.add quote do:
                        `config` = `tomlField`.getElems().mapIt(it.getString())
                of "int":
                    result.add quote do:
                        `config` = `tomlField`.getElems().mapIt(it.getInt())
                of "bool":
                    result.add quote do:
                        `config` = `tomlField`.getElems().mapIt(it.getBool())
                else:
                    assert(false, "Unknown field type: " & fieldType.strVal)
        of nnkEnumTy:
            var typename = config.getTypeImpl[1]
            result.add quote do:
                `config` = `tomlField`.getElems().mapIt(`typename`(parseEnum[
                        `typename`](it.getStr())))
        else:
            assert(false, "Unknown type in sequence: " & fieldType.repr)
    else:
        echo(configType.kind)
        echo(result.repr)


# ----------------------------------------------------------------------- #

const Compatible = @[strings.NimblePkgVersion]

proc isCompatible*(configVersion: string, outVersion: var string): bool =
    for item in Compatible:
        if configVersion != item:
            continue

        return true

    return false

proc checkCompatibility(version: string) {.raises: [Exception].} =
    var outVersion: string
    if not isCompatible(version, outVersion):
        raiseError(Error.OutdatedConfig, version, strings.NimblePkgVersion)

proc initialize*(): Config =
    var configFile: Config

    try:
        var toml = parseFile(config.ConfigFilePath)

        parseFields(toml, configFile)
        checkCompatibility(configFile.debug.version)

        if len(configFile.build.targets) == 0:
            raiseError(Error.NoTargets)
        else:
            configFile.build.targets = deduplicate(configFile.build.targets)

        if isEmptyOrWhitespace(configFile.build.searchPath):
            configFile.build.searchPath = ConfigDirectory
    except IOError:
        raiseError(Error.NoConfig)
    except TomlError as e:
        raiseError(Error.InvalidConfig, e.msg)

    if configFile.debug.logging:
        logger.initialize(LogFilePath)

    return configFile
