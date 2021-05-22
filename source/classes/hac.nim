import console
export console

import tables

import strformat
import strutils

let meta_cmd = "nacptool --create '$1' '$2' $3 $4.nacp"
let bin_cmd  = "elf2nro $1 $2.nro --icon=$3 --nacp=$2.nacp"

type
    HAC* = ref object of Console

method publish(self : HAC, source : string) : bool =
    let binaryPath = fmt("{self.getBuildDirectory()}/{self.name}")

    # Create metadata
    runCommand(meta_cmd.format(self.name, self.author, self.version, binaryPath))

    # Create binary
    runCommand(bin_cmd.format(self.getBinary(), self.name, self.getIcon()))

    return self.packGameDirectory(source)

method getName(self : HAC) : string =
    return "Nintendo Switch"
