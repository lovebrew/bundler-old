import tables, os

var paths = initTable[string, string]()

proc getPath*(name : string) : string =
    return paths[name]

paths["FIRST_RUN_FILE"] = normalizedPath(getConfigDir() & "/.lovebrew/.first_run")

paths["CONFIG_FILE"] = normalizedPath(getCurrentDir() & "/lovebrew.toml")
