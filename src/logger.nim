import logging

var logger: FileLogger = nil
const FormatString = "$levelname [$time] -- $appname: "

proc initialize*(path: string) =
    logger = newFileLogger(path, fmWrite, lvlAll, FormatString)
    logging.log(logger, lvlInfo, "Initialize..")

proc log(level: Level, args: varargs[string, `$`]) =
    if logger.isNil():
        return

    logging.log(logger, level, args)
    io.flushFile(logger.file)

proc info*(args: varargs[string, `$`]) =
    logger.log(lvlInfo, args)

proc warning*(args: varargs[string, `$`]) =
    logger.log(lvlWarn, args)

proc error*(args: varargs[string, `$`]) =
    logger.log(lvlError, args)
