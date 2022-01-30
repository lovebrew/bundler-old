import logging

var logger: FileLogger = nil
const FormatString = "$datetime | $levelname | "

proc load*(filepath: string, enabled: bool) =
    if enabled:
        logger = newFileLogger(filepath, fmWrite, lvlAll, FormatString)

proc log(level: Level, message: string) =
    if logger == nil:
        return

    logger.log(level, message)
    io.flushFile(logger.file)

proc info*(message: string) =
    log(lvlInfo, message)

proc warning*(message: string) =
    log(lvlWarn, message)

proc error*(message: string) =
    log(lvlError, message)
