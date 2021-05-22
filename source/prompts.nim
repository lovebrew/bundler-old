import strutils, os

{.experimental: "codeReordering".}

proc show*(prompt : string) =
    echo "\n" & prompt

proc showFormatted*(prompt : string, args : varargs[string]) =
    show(prompt.format(args))

proc findBinary*(name : string) : bool =
    if not findExe(name).isEmptyOrWhitespace():
        return true
    BINARY_FOUND_NO_PATH.showFormatted(name)

const FIRST_RUN* = """
This software is not endorsed nor maintained by devkitPro.
If there are issues, please report them to the GitHub repository:
https://github.com/TurtleP/lovebrew
"""

const DEVKITPRO* = """
The DEVKITPRO environment variable is not set.
Please install the devkit-env package from devkitpro-pacman.
If you are on Windows, add it to your PATH environment variable instead.
"""

const CONFIG_NOT_FOUND* = """
Config not found! Try creating one with the init argument.
"""

const SOURCE_NOT_FOUND* = """
Could not find the source directory '$1'! Please double check your
configuration file for misspellings or errors.
"""

const BINARY_FOUND_NO_PATH* = """
Binary '$1' is not in your PATH environment.
On macOS and Linux, install the devkit-env package. Windows users need
to add the path 'C:\devkitPro\tools\bin' to their PATH.
"""

const BUILD_FAIL* = """
Could not build the project '$1' for $2!
The ELF binary ($3) at path $4 does not exist!
Aborting!
"""

const BAD_CONFIG* = """
Failed to load config properly (corrupt or old version).
Please create a fresh one with the init command.
"""
when isMainModule:
    import unittest
    test "Find Binary":
        check not findBinary("asdf")
        check findBinary("echo")
