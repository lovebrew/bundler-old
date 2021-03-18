import tables, os

var paths = initTable[string, string]()

proc getPath*(name : string) : string =
    return paths[name]

paths["FIRST_RUN_FILE"] = normalizedPath(getHomeDir() & "/.first_run")

paths["CONFIG_FILE"] = normalizedPath(getCurrentDir() & "/lovebrew.toml")

paths["BIN_DIR_WIN"] = "C:\\devkitPro\\tools\\bin\\"
paths["BIN_DIR_LINUX"] = "/opt/devkitpro/tools/bin/"
