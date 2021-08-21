import os
import sequtils
import strutils

import configure
import strings

import types/target

let FirstRunFile = ConfigDirectory & "/.first_run"
let CurrentDirectory* = getCurrentDir()

proc findBinary(name: string): bool =
    var package = case name:
        of "tex3ds":
            name
        of "nacptool":
            "switch-tools"
        else:
            "3dstools"

    if isEmptyOrWhitespace(findExe(name)):
        raise newException(Exception, strings.BinaryNotFound.format(name, package))

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

    let targets = config.targets
    var pass = false

    if Target_Ctr in targets:
        pass = ctrBinaries.allIt(it.findBinary)

    if Target_Hac in targets:
        pass = hacBinaries.anyIt(it.findBinary)

    return pass

if not fileExists(FirstRunFile):
    os.createDir(ConfigDirectory)
    writeFile(FirstRunFile, "")

    echo(FirstRun)
    quit(0)
