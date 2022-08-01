import strutils
import strformat

import ../logger

### String for prompts/errors

const NimblePkgVersion* {.strdefine.} = ""

### Error Enums

type
    Error* = enum
        DevkitPro = "The DEVKITPRO environment variable is not set."
        NoTargets = "No targets were specified."
        Source = "Source directory `$1` does not exist."
        NoConfig = "Configuration file not found."
        OutdatedConfig = "Incompatible config version `$1`."
        InvalidConfig = "Configuration file is invalid: $1"
        ConfigOverwrite = "Config file was not created: $1"
        ToolNotFound = "Tool `$1` could not be found."
        ToolFoundNotInPath = "The tool `$1` exists, but is not in your PATH environment."
        CompileBinaryNotfound = "Binary `$1` was not found."
        FirstRun = "This software is not endorsed nor maintained by devkitPro.\nPlease report issues to the GitHub repository:\nhttps://github.com/lovebrew/lovebrew"

proc displayError*(error: Error, args: varargs[string, `$`]) =
    echo(fmt("Error: {($error).format(args)}."))

proc raiseError*(error: Error, args: varargs[string, `$`]) =
    raise newException(Exception, fmt("Error: {($error).format(args)} Aborting."))

proc formatError*(error: Error, args: varargs[string, `$`]): string =
    return fmt("{($error).format(args)} Aborting.")

### Build Enums

type
    BuildStatus* = enum
        Success = "Build for $1 was successful."
        Failure = "Build for $1 failed."

proc displayBuildStatus*(status: BuildStatus, args: varargs[string, `$`]) =
    echo(($status).format(args))

    if (status == BuildStatus.Failure):
        if (logger.isActive()):
            echo(fmt("Check log for details."))
        else:
            echo("Please enable logging and re-run.")

type
    LogData* = enum
        InitializeBuild = "-- $1 --"

        ExecuteCommand = "Executing command..."
        CommandRunning = "  $1"
        CommandError = "Command Error: $1"
        CommandSuccess = "Command executed successfully."
        CommandOSError = "Command Error:\n$1"

        PackingGameContent = "Packing game content..."
        PackingGameContentSuccess = "Content packed successfully."
        PackingGameContentError = "Error packing game content: $1"

        ConvertFile = "Converting file..."
        CopyFile = "Copying file..."

        HandleFile = "  $1 -> $2"
        SourceUnchanged = "  Source file $1 is not newer than $2. Skipping."
        HandleFileError = "Failed to handle file $1: $2"

        Cleaning = "Cleaning build directory..."
        CleanFile = "  $1"

proc formatLog*(data: LogData, args: varargs[string, `$`]): string =
    return ($data).format(args)

### Others

const ConfigExists* = """
Config file already exists in this directory. Overwrite? [y/N]:"""
