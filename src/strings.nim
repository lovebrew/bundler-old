import strformat
import strutils

const NimblePkgVersion* {.strdefine.} = ""

### Error Enums

type
    Error* = enum
        OutdatedConfig = "Incompatible configuration version `$1`."
        NoConfig = "Configuration file not found."
        InvalidConfig = "Configuration file is invalid: $1"
        ConfigOverwrite = "Configuration file was not created: $1"

proc raiseError*(error: Error, args: varargs[string, `$`]) =
    raise newException(Exception, &"Error: {($error).format(args)} Aborting.")

### Other

const ConfigExists* = "A config file already exists in this directory. Overwrite? [y/N]:"
