import os
import sequtils
import strutils

import data/strings
import data/assets

import enums/target

import regex

proc findBinary(name: string): bool =
    var package = case name:
        of "tex3ds":
            name
        of "nacptool":
            "switch-tools"
        else:
            "3dstools"

    if isEmptyOrWhitespace(os.findExe(name)):
        raise newException(Exception, strings.BinaryNotFound.format(name, package))

    return true

let compatible = @[strings.NimblePkgVersion, "0.5.4", "0.5.3",
                   "0.5.2", "0.5.1", "0.5.0"]

proc isCompatible*(configVersion: string, outVersion: var string): bool =
    let versionRegex = re"# VERSION (.+) #"
    var match: RegexMatch

    let findVersion = regex.find(assets.DefaultConfigFile, versionRegex, match)
    if findVersion:
        for item in compatible:
            if configVersion != item:
                continue

            return true

    outVersion = match.groupFirstCapture(0, assets.DefaultConfigFile)
    return false

proc checkToolchainInstall*(targets: seq[Target]): bool =
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

    var pass = false

    if TARGET_CTR in targets:
        pass = ctrBinaries.allIt(it.findBinary)

    if TARGET_HAC in targets:
        pass = hacBinaries.anyIt(it.findBinary)

    return pass
