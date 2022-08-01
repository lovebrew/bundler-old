import logging

var logger: FileLogger = nil

var filepath: string = ""
const FormatString = "$levelname [$time] -- $appname: "

proc initialize*(path: string) =
    filepath = path

    logger = newFileLogger(path, fmWrite, lvlAll, FormatString)
    logging.log(logger, lvlInfo, "Initialize..")

proc getFilepath*(): string =
    return filepath

proc isActive*(): bool =
    return (logger.isNil == false)

proc logLevel(level: Level, args: varargs[string, `$`]) =
    if not isActive():
        return

    logging.log(logger, level, args)
    io.flushFile(logger.file)

proc info*(arg: string) =
    logLevel(lvlInfo, arg)

proc warning*(arg: string) =
    logLevel(lvlWarn, arg)

proc error*(arg: string) =
    logLevel(lvlError, arg)
