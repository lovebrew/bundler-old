### String for prompts/errors

const FirstRun* = """
This software is not endorsed nor maintained by devkitPro.
If there are issues, please report them to the GitHub repository:
https://github.com/lovebrew/lovebrew
"""

### Errors

const NoDevkitPro* = """
The DEVKITPRO environment variable is not set.
Linux/macOS Users: install the devkit-env package from devkitpro-pacman.
If you are on Windows, add DEVKITPRO to your PATH environment variable instead.
"""

const NoTargets* = """
Cannot compile. Targets were not specified in lovebrew.toml!
"""

const NoSource* = """
Cannot compile. Source directory '$1' does not exist or config
variable is empty in lovebrew.toml! Please double check your
configuration file for misspellings or errors.
"""

const NoConfig* = """
Config not found! Try creating one with the init argument.
"""

const BinaryNotFound* = """
Binary '$1' is not in your PATH environment.
On macOS and Linux, install the devkit-env package. Windows users need
to add the path 'C:\devkitPro\tools\bin' to their PATH.
"""

const ElfBinaryNotFound* = """
Could not build the project '$1' for $2!
Ensure the ELF binary ($3) is at the following path:
$4
"""

### Build Status

const BuildSuccess* = """
Build for $1 was successful. Please check the directory
'$2' for your files.
"""

const BuildFailure* = """
Build for $1 failed. Please check logs.
"""

### Others

const ConfigExists* = """
Config file already exists in this directory. Overwrite? [y/N]:
"""

const ConfigOverwriteFailed* = """
"Config file was not overwritten due to an error:"
"""
