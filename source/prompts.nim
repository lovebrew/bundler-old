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
