import tables, strutils, os, paths

var prompts = initTable[string, string]()

proc showPrompt*(name : string) =
    echo("\n" & prompts[name])

proc findBinary*(name : string) : bool =
    var path = when defined windows:
                    getConfigPath("BIN_DIR_WIN")
               elif defined linux:
                    getConfigPath("BIN_DIR_LINUX")

    let binaryPath = normalizedPath(path & name)

    if not fileExists(binaryPath):
        showPrompt(name.toUpper())
        return false

    return true

prompts["FIRST_RUN"] = """
This software is not endorsed nor maintained by devkitPro.
If there are issues, please report them to the GitHub repository:
https://github.com/TurtleP/lovebrew
"""

prompts["DEVKITPRO"] = """
The DEVKITPRO environment variable is not set.
Please install the devkit-env package from devkitpro-pacman.
If you are on Windows, add it to your PATH environment variable instead.
"""

prompts["CONFIG_NOT_FOUND"] = """
Config not found! Try creating one with the init argument.
"""

prompts["3DSXTOOL"] = """
The binary "3dsxtool" could not be found.
Please install the 3dstools package from devkitpro-pacman.
"""

prompts["TEX3DS"] = """
The binary "tex3ds" could not be found.
Please install the tex3ds package from devkitpro-pacman.
"""

prompts["NACPTOOL"] = """
The binary "nacptool" could not be found.
Please install the switch-tools package from devkitpro-pacman.
"""

prompts["BINARY_FOUND_NO_PATH"] = """
Binary '$1' is not in your PATH environment.
On macOS and Linux, install the devkit-env package. Windows users need
to add the path 'C:\devkitPro\tools\bin' to their PATH.
"""
