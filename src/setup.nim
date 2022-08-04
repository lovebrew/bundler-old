import os
import sequtils
import strutils

import data/strings

import types/config

import enums/tool
import enums/target

proc initialize*() =
    if not os.dirExists(config.ConfigDirectory):
        os.createDir(config.ConfigDirectory)

    if not fileExists(config.FirstRunFile):
        writeFile(FirstRunFile, "")
        raise newException(Exception, $Error.FirstRun)

proc findBinary(name: Tool): bool =
    if isEmptyOrWhitespace(os.findExe($name)):
        strings.raiseError(Error.ToolNotFound, $name)

    return true

proc check*(targets: seq[Target]): bool =
    if not os.existsEnv("DEVKITPRO"):
        strings.raiseError(Error.DevkitPro)

    ## Check for 3DS and Switch requirements

    let ctrBinaries = @[Tool.Tex3ds, Tool.HbUpdater]
    let hacBinaries = @[Tool.HbUpdater]

    var pass = false

    if TARGET_CTR in targets:
        pass = ctrBinaries.allIt(it.findBinary)

    if TARGET_HAC in targets:
        pass = hacBinaries.anyIt(it.findBinary)

    return pass
