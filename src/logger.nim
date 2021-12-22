import logging

var logger: FileLogger
var isEnabled: bool = false

proc load*(filepath: string, enabled: bool) =
    if enabled:
        logger = newFileLogger(filepath, fmWrite, levelThreshold=lvlAll, fmtStr="$datetime | $levelname | ")
        info("Initializing logger..")

    isEnabled = enabled

proc info*(message: string) =
    if not isEnabled:
        return

    logger.log(lvlInfo, message)
    flushFile(logger.file)

proc warning*(message: string) =
    if not isEnabled:
        return

    logger.log(lvlWarn, message)
    flushFile(logger.file)

proc error*(message: string) =
    if not isEnabled:
        return

    logger.log(lvlError, message)
