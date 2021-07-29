import os
import strutils
import strformat

import console
export console

import ../assetsfile
import ../configure
import ../strings

const ZipCommand = """cd "$1"; zip -r -9 $2 ."""
const NacpCommand = """cd "$1"; nacptool --create "$2" "$3" "$4" "$5.nacp""""
const BinaryCommand = """cd "$1"; elf2nro "$2" "$3.nro" --icon="$4" --nacp="$3.nacp" --romfsdir="romfs""""

type
    Hac* = ref object of ConsoleBase

proc getBinaryExtension*(self: Hac): string = "nro"
proc getConsoleName*(self: Hac): string = "Nintendo Switch"
proc getElfBinaryName*(self: Hac): string = "switch.elf"
proc getIconExtension*(self: Hac): string = "jpg"

proc publish*(self: Hac) =
    ### Write the needed shaders to their proper directory
    os.createDir(fmt("{config.build}/romfs/shaders"))
    for key, value in HacShaders.items():
        writeFile(fmt("{config.build}/romfs/shaders/{key}.dksh"), value)

    let elfBinaryPath = self.getElfBinaryPath()
    let name = config.name

    if not os.fileExists(elfBinaryPath):
        raise newException(Exception, strings.ElfBinaryNotFound.format(
                name, self.getConsoleName(), self.getElfBinaryName(),
                config.binSearchPath))

    let build = config.build
    let currentDir = getCurrentDir()
    let lovePath = fmt("{build}/{config.outputName}.love")

    ### Create `SuperGame`.love in the build directory
    console.runCommand(ZipCommand.format(config.source, fmt("{currentDir}/{lovePath}")))

    let outputName = config.outputName

    ### Create `SuperGame`.nacp in the build directory
    console.runCommand(NacpCommand.format(build, name, config.author, config.version, outputName))

    ### Create `SuperGame`.nro in the build directory
    console.runCommand(BinaryCommand.format(build, elfBinaryPath, outputName, fmt("{currentDir}/{self.getIcon()}")))

    let outputBinaryPath = self.getOutputBinaryPath()

    ### Finalize `SuperGame`.nro in the build directory
    writeFile(outputBinaryPath, readFile(outputBinaryPath) & readFile(lovePath))
