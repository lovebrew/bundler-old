import os
import strutils
import strformat

import console
export console

import ../assetsfile
import ../configure
import ../strings

const NacpCommand = """nacptool --create "$1" "$2" "$3" "$4.nacp""""
const BinaryCommand = """elf2nro "$1" "$2.nro" --icon="$3" --nacp="$4.nacp" --romfsdir="./shaders""""

type
    Hac* = ref object of ConsoleBase

proc getBinaryExtension*(self: Hac): string = "nro"
proc getConsoleName*(self: Hac): string = "Nintendo Switch"
proc getElfBinaryName*(self: Hac): string = "Switch.elf"
proc getIconExtension*(self: Hac): string = "jpg"

proc publish*(self: Hac, source: string) =
    ### Write the needed shaders to their proper directory

    os.createDir("shaders")
    for key, value in HacShaders.items():
        writeFile(fmt("shaders/{key}.dksh"), value)

    let elfBinaryPath = self.getElfBinaryPath()

    if not os.fileExists(elfBinaryPath):
        echo(strings.ElfBinaryNotFound.format(
                config.name, self.getConsoleName(), self.getElfBinaryName(),
                config.binSearchPath))
        return

    let tempBinaryPath = self.getTempMetadataBinaryPath()

    ### Create `LOVEPotion.nacp` in `build`
    console.runCommand(NacpCommand.format(config.name, config.author, config.version, tempBinaryPath))

    ### Create `LOVEPotion.nro` in `build`
    console.runCommand(BinaryCommand.format(elfBinaryPath, tempBinaryPath, self.getIcon(), tempBinaryPath))

    self.packGameDirectory(fmt("{source}/"))
