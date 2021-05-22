import tables, strutils, os

var prompts = initTable[string, string]()

proc showPrompt*(name : string) =
    echo("\n" & prompts[name])

proc showPromptFormatted*(name : string, args : varargs[string]) =
    echo("\n" & prompts[name].format(args))

proc findBinary*(name : string) : bool =
    if findExe(name).isEmptyOrWhitespace():
        echo("\n" & prompts["BINARY_FOUND_NO_PATH"].format(name))

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

prompts["SOURCE_NOT_FOUND"] = """
Could not find the source directory '$1'! Please double check your
configuration file for misspellings or errors.
"""

prompts["BINARY_FOUND_NO_PATH"] = """
Binary '$1' is not in your PATH environment.
On macOS and Linux, install the devkit-env package. Windows users need
to add the path 'C:\devkitPro\tools\bin' to their PATH.
"""

prompts["BUILD_FAIL"] = """
Could not build the project '$1' for $2!
The ELF binary ($3) at path $4 does not exist!
Aborting!
"""

prompts["BAD_CONFIG"] = """
Failed to load config properly (corrupt or old version).
Please create a fresh one with the init command.
"""
