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
    logger.info(fmt"== [{self.getConsoleName()}] ==")

    ### Write the needed shaders to their proper directory

    os.createDir(ShadersDirectory)
    for key, value in HacShaders.items():
        if not fileExists(fmt"{ShadersDirectory}/{key}.dksh"):
            logger.info(fmt"Writing shader: {ShadersDirectory}/{key}.dksh")
            writeFile(fmt("{ShadersDirectory}/{key}.dksh"), value)
        else:
            logger.info(fmt"Shader '{key}.dksh' already exists. Skipping.")

    let elfBinaryPath = self.getElfBinaryPath()

    if not os.fileExists(elfBinaryPath):
        echo(strings.ElfBinaryNotFound.format(
                config.name, self.getConsoleName(), self.getElfBinaryName(),
                config.binSearchPath))
        return false

    let outputPath = self.getGenericOutputBinaryPath()

    try:
        os.createDir(RomFSDirectory)

        # Copy RomFS graphics content to directory
        for name, content in HacGraphics.items():
            if not fileExists(fmt"{RomFSDirectory}/{name}"):
                writeFile(fmt"{RomFSDirectory}/{name}", content)
            else:
                logger.info(fmt"Messagebox texture '{name}' already exists. Skipping.")

        let (head, _) = splitPath(RomFSDirectory)

        ### Create `{SuperGame}.nacp` in `build`
        if not console.runCommand(NacpCommand.format(config.name, config.author, config.version, outputPath)):
            return false

        ### Create `{SuperGame}.nro` in `build`
        if not console.runCommand(BinaryCommand.format(elfBinaryPath, outputPath, self.getIcon(), outputPath, head)):
            return false
    except Exception as e:
        logger.error(fmt"{self.getConsoleName()} publishing failure: {e.msg}")
        return false

    return self.packGameDirectory(fmt("{source}/"))
