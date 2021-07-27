import os
import sequtils
import strutils

import configure
import strings

let FirstRunFile = ConfigDirectory & "/.first_run"

proc findBinary(name: string): bool =
    if isEmptyOrWhitespace(findExe(name)):
        raise newException(Exception, strings.BinaryNotFound.format(name))

    return true

proc checkToolchainInstall*(): bool =
    if not os.existsEnv("DEVKITPRO"):
        raise newException(Exception, strings.NoDevkitPro)

    ## Check for 3DS and Switch requirements
    ##
    ## 3dsxtool and smdhtool are provided by 3dstools
    ## so we only need to check for one of them
    ## tex3ds and mkbcfnt are provided by tex3ds
    ##
    ## nacptool and elf2nro are provided by switch-tools
    ## so we only need to check for one of them

    let ctrBinaries = @["3dsxtool", "tex3ds"]
    let hacBinaries = @["nacptool"]

    return ctrBinaries.anyIt(it.findBinary) or hacBinaries.anyIt(it.findBinary)

if not fileExists(FirstRunFile):
    os.createDir(ConfigDirectory)
    io.writeFile(FirstRunFile, "")

    echo(FirstRun)
    quit(0)
