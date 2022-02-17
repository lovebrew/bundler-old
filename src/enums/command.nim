import osproc
import strutils

import ../logger
import ../data/strings

type
    Command* = enum
        Tex3ds = "tex3ds $1 --border=transparent -o $2"
        Mkbcfnt = "mkbcfnt $1 -o $2"

        Smdhtool = "smdhtool --create $1 $2 $3 $4 $5.smdh"
        Nacptool = "nacptool --create $1 $2 $3 $4.nacp"

proc run*(command: string, args: varargs[string, `$`]): bool =
    let commandString = command.format(args).replace("\\", "/")
    let execResult = osproc.execCmdEx(commandString)

    if execResult.exitCode != 0:
        logger.warning(formatLog(LogData.CommandError, command,
                execResult.output))
        return false

    return true
