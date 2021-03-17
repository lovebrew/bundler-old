import tables, os

var paths = initTable[string, string]()

proc getConfigPath*(name : string) : string =
    return paths[name]

paths["FIRST_RUN_FILE"] = getHomeDir() & "/.first_run"

paths["CONFIG_FILE"] = getCurrentDir() & "/lovebrew.toml"
