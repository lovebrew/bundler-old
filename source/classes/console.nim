import osproc
import typetraits

type
    Console* = ref object of RootObj

        app_name: string
        author: string
        description: string
        version: string

method run_command(self: Console, command: string) {.base.} =
    ## Runs a specified command
    let output = execCmdEx(command)

method get_icon*(self: Console) {.base.} =
    var suffix = ".png"

    if self.type.name == "HAC":
        suffix = ".jpg"
