import osproc
import strformat
import strutils

import ../config

type
    Console* = ref object of RootObj

        name*: string
        author*: string
        description*: string
        version*: string

method runCommand*(self : Console, command : string) {.base.} =
    ## Runs a specified command
    discard execCmd(command)

method compile*(self : Console, source : string) {.base, locks: "unknown".} =
    echo ""

method getName(self : Console) : string {.base.} =
    return "Console"

method getIcon*(self : Console) : string {.base.} =
    var suffix = "png"

    if "Switch" in self.getName():
        suffix = "jpg"

    let path = getBuildValue("icon")
    return fmt("{path}{suffix}")
