import os
import sequtils
import strutils

import data/strings

import enums/package
import enums/target

proc findDevkitProBinary(name: Package): bool =
    if isEmptyOrWhitespace(os.findExe($name)):
        strings.raiseError(strings.ToolNotFound, name, $name)

    return true

proc check*(targets: seq[Target]): bool =
    if not os.existsEnv("DEVKITPRO"):
        strings.raiseError(strings.Error.DevkitPro)

    ## Check for 3DS and Switch requirements
    ##
    ## 3dsxtool and smdhtool are provided by 3dstools
    ## so we only need to check for one of them
    ## tex3ds and mkbcfnt are provided by tex3ds
    ##
    ## nacptool and elf2nro are provided by switch-tools
    ## so we only need to check for one of them

    let ctrBinaries = @[Package.Tex3ds, Package.Smdhtool]
    let hacBinaries = @[Package.Nacptool]

    var pass = false

    if TARGET_CTR in targets:
        pass = ctrBinaries.allIt(it.findDevkitProBinary)

    if TARGET_HAC in targets:
        pass = hacBinaries.anyIt(it.findDevkitProBinary)

    return pass
