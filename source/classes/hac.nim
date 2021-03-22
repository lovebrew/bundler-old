import console
export console

import tables
import strutils
import strformat
import os

import ../prompts
import ../config

## Command line stuff to run
var COMMANDS : Table[string, string]

COMMANDS["meta"]    = "nacptool --create '$1' '$2' '$3' '$1'.nacp"
COMMANDS["binary"]  = "elf2nro $1 '$2'.nro --icon=$3 --nacp='$2'.nacp --romfsdir=$4"

type
    HAC* = ref object of Console

method getName(self : HAC) : string =
    return "Nintendo Switch"

method compile(self : HAC, source : string) =
    # Get our important directories
    let romFSDirectory = self.getRomFSDirectory()
    let buildDirectory = self.getBuildDirectory()

    # Ensure the required ELF binary exists. If it doesn't, we should abort and inform the user.
    # This should only be an issue if compiling non-raw builds
    let elfBinaryFull = self.getElfBinary()

    if not elfBinaryFull.fileExists() and not config.getOutputValue("raw").getBool():
        showPromptFormatted("BUILD_FAIL", source, self.getName(), self.getElfBinaryName(), self.getElfBinaryPath())
        return

    # Create the nacp metadata
    let outputFile = fmt("{buildDirectory}/{self.name}")
    # let properDescription = fmt("{self.description} • {self.version}")


    self.runCommand(COMMANDS["meta"].format(self.name, self.author, self.version, outputFile))

    # Create the nro binary
    self.runCommand(COMMANDS["binary"].format(elfBinaryFull, outputFile, self.getIcon(), romFSDirectory))
