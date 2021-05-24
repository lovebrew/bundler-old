import os, tables

import ../prompts
import configfile

var ignoreList* = @[".git", ".vscode"]

let FIRST_RUN_FILE* = normalizedPath(CONFIG_DIRECTORY & "/.first_run")
let CONFIG_FILE*    = normalizedPath(getCurrentDir() & "/lovebrew.toml")

proc loadConfigFile*(path : string = "") : bool =
    ## Load the Config File data

    if not CONFIG_FILE.fileExists():
        CONFIG_NOT_FOUND.show()
        return false

    Config = ConfigData(filepath: CONFIG_FILE)

    try:
        return Config.load()
    except Exception:
        BAD_CONFIG.show()

    return false

template makeConsoleChild*(child : type) : untyped =
    let meta = Config.getMetadata()

    console = child(name: meta.name, author: meta.author,
                 description: meta.description, version: meta.version)
