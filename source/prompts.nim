import tables

var prompts = initTable[string, string]()

proc showPrompt*(name : string) =
    echo("\n" & prompts[name])

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
