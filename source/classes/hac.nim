import console
export console

import tables
import strutils

import os

import ../config/configfile
import ../prompts

let meta_cmd = "nacptool --create '$1' '$2' $3 $4.nacp"
let bin_cmd  = "elf2nro $1 $2.nro --icon=$3 --nacp=$2.nacp"

type HAC* = ref object of ConsoleBase

proc getName*(self : HAC) : string = "Nintendo Switch"
proc getBinaryName*(self : HAC) : string = "Switch.elf"
proc getIconExtension*(self: HAC) : string = "jpg"
proc getExtension*(self : HAC) : string = "nro"

proc publish(self : HAC, source : string) : bool =
    let elfBinaryPath = self.getBinaryPath()

    if not elfBinaryPath.fileExists() and not Config.shouldOutputRawData():
        BUILD_FAIL.showFormatted(source, self.getName(), self.getBinaryName(), self.getBinaryPath())
        return false

    # Create metadata
    runCommand(meta_cmd.format(self.name, self.author, self.version, elfBinaryPath))

    # Create binary
    runCommand(bin_cmd.format(self.getBinaryPath(), self.name, self.getIcon()))

    return self.packGameDirectory(source)

when isMainModule:
    import unittest
    test "Name":
        var switch = HAC(name: "my game", author: "me", description: "cool", version: "1.2")
        check switch.getName() == "Nintendo Switch"
        check switch.getProjectName() == "my game"
        check switch.getBinaryName() == "Switch.elf"
        check switch.getIconExtension() == "jpg"
        check switch.getExtension() == "nro"
