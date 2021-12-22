import os
import strutils
import strformat

import console
export console

import ../assetsfile
import ../configure
import ../strings
import ../logger

const NacpCommand = """nacptool --create "$1" "$2" "$3" "$4.nacp""""
const BinaryCommand = """elf2nro "$1" "$2.nro" --icon="$3" --nacp="$4.nacp" --romfsdir="$5""""

const ShadersDirectory = "romfs/hac/shaders"
const RomFSDirectory = "romfs/hac/graphics"

type
    Hac* = ref object of ConsoleBase

proc getBinaryExtension*(self: Hac): string = "nro"
proc getConsoleName*(self: Hac): string = "Nintendo Switch"
proc getElfBinaryName*(self: Hac): string = "Switch.elf"
proc getIconExtension*(self: Hac): string = "jpg"

proc publish*(self: Hac, source: string): bool =
    ### Write the needed shaders to their proper directory

    os.createDir(ShadersDirectory)
    for key, value in HacShaders.items():
        logger.info(fmt"Writing shader: {ShadersDirectory}/{key}.dksh")
        writeFile(fmt("{ShadersDirectory}/{key}.dksh"), value)

    let elfBinaryPath = self.getElfBinaryPath()

    if not os.fileExists(elfBinaryPath):
        echo(strings.ElfBinaryNotFound.format(
                config.name, self.getConsoleName(), self.getElfBinaryName(),
                config.binSearchPath))
        return

    let outputPath = self.getGenericOutputBinaryPath()

    try:
        os.createDir(RomFSDirectory)

        # Copy RomFS graphics content to directory
        for name, content in HacGraphics.items():
            writeFile(fmt"{RomFSDirectory}/{name}", content)

        let (head, _) = splitPath(RomFSDirectory)

        ### Create `{SuperGame}.nacp` in `build`
        console.runCommand(NacpCommand.format(config.name, config.author, config.version, outputPath))

        ### Create `{SuperGame}.nro` in `build`
        console.runCommand(BinaryCommand.format(elfBinaryPath, outputPath, self.getIcon(), outputPath, head))
    except Exception as e:
        logger.error(fmt"{self.getConsoleName()} publishing failure: {e.msg}")
        return false

    return self.packGameDirectory(fmt("{source}/"))
