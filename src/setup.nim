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

proc findDevkitProBinary(name: Tool): bool =
    if isEmptyOrWhitespace(os.findExe($name)):
        strings.raiseError(Error.ToolNotFound, $name)

    return true

proc check*(targets: seq[Target]): bool =
    if not os.existsEnv("DEVKITPRO"):
        strings.raiseError(Error.DevkitPro)

    ## Check for 3DS and Switch requirements
    ##
    ## 3dsxtool and smdhtool are provided by 3dstools
    ## so we only need to check for one of them
    ## tex3ds and mkbcfnt are provided by tex3ds
    ##
    ## nacptool and elf2nro are provided by switch-tools
    ## so we only need to check for one of them

    let ctrBinaries = @[Tool.Tex3ds, Tool.Smdhtool]
    let hacBinaries = @[Tool.Nacptool]

    var pass = false

    if TARGET_CTR in targets:
        pass = ctrBinaries.allIt(it.findDevkitProBinary)

    if TARGET_HAC in targets:
        pass = hacBinaries.anyIt(it.findDevkitProBinary)

    return pass
