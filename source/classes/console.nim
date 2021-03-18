import osproc
import strformat
import strutils

import os

type
    Console* = ref object of RootObj

        name*: string
        author*: string
        description*: string
        version*: string

method run_command(self: Console, command: string) {.base.} =
    ## Runs a specified command
    let output = execCmdEx(command)

method compile*(self: Console) {.base.} =
    echo ""

method getName(self: Console) : string {.base.} =
    return "Console"

method get_icon*(self: Console) : string {.base.} =
    var suffix = "png"

    if "Switch" in self.getName():
        suffix = "jpg"

    return fmt("icon.{suffix}")
