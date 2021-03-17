import osproc
import strformat
import strutils

type
    Console* = ref object of RootObj

        app_name*: string
        author*: string
        description*: string
        version*: string

method run_command(self: Console, command: string) {.base.} =
    ## Runs a specified command
    let output = execCmdEx(command)

method console_name(self: Console) : string {.base.} =
    return "Console"

method get_icon*(self: Console) : string {.base.} =
    var suffix = "png"

    if "Switch" in self.console_name():
        suffix = "jpg"

    return fmt("icon.{suffix}")
