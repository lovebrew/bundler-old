import logging

var logger: FileLogger = nil
const FormatString = "$levelname [$time] -- $appname: "

proc init*(path: string, enable: bool) =
    if enable:
        logger = newFileLogger(path, fmWrite, lvlAll, FormatString)

proc logLevel(level: Level, args: varargs[string, `$`]) =
    if logger.isNil:
        return

    logging.log(logger, level, args)
    io.flushFile(logger.file)

proc info*(arg: string) =
    logLevel(lvlInfo, arg)

proc warning*(arg: string) =
    logLevel(lvlWarn, arg)

proc error*(arg: string) =
    logLevel(lvlError, arg)
