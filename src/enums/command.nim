import osproc
import strutils

import ../logger
import ../data/strings

type
    Command* = enum
        Tex3ds = "tex3ds $1 -o $2"
        Mkbcfnt = "mkbcfnt $1 -o $2"

        CtrUpdate = "hbupdater ctr --filepath $1 --title \"$2\" --author \"$3\" --description \"$4\" --iconPath $5 --output $6"
        CtrUpdateNoIcon = "hbupdater ctr --filepath $1 --title \"$2\" --author \"$3\" --description \"$4\" --output $5"

        HacUpdate = "hbupdater hac --filepath $1 --title \"$2\" --author \"$3\" --iconPath $4 --output $5"
        HacUpdateNoIcon = "hbupdater hac --filepath $1 --title \"$2\" --author \"$3\" --output $4"

proc run*(command: string, args: varargs[string, `$`]): bool =
    let commandString = command.format(args).replace("\\", "/")
    logger.info(formatLog(LogData.ExecuteCommand))

    logger.info(formatLog(LogData.CommandRunning, commandString))

    try:
        let execResult = osproc.execCmdEx(commandString)

        if (execResult.exitCode != 0):
            logger.warning(formatLog(LogData.CommandError, execResult.output))
            return false
        else:
            logger.info(formatLog(LogData.CommandSuccess))
    except OSError as e:
        logger.warning(formatLog(LogData.CommandError, e.msg))
        return false

    return true
