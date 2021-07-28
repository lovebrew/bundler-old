import os
import strutils
import strformat

import console
export console

import ../configure
import ../strings

const TextureCommand = "tex3ds '$1' --format=rgba8888 -z=auto --border -o '$2.t3x'"
const FontCommand = "mkbcfnt '$1' -o '$2.bcfnt"

const SmdhCommand = "smdhtool --create '$1' '$2' '$3' '$4' '$5.smdh'"
const BinaryCommand = "3dsxtool '$1' '$2.3dsx' --smdh='$2.smdh'"

const Textures = @[".png", ".jpg", ".jpeg"]
const Fonts = @[".ttf", ".otf"]

type
    Ctr* = ref object of ConsoleBase

proc getBinaryExtension*(self: Ctr): string = "3dsx"
proc getConsoleName*(self: Ctr): string = "Nintendo 3DS"
proc getElfBinaryName*(self: Ctr): string = "3DS.elf"
proc getIconExtension*(self: Ctr): string = "png"

proc convertFiles(self: Ctr, source: string) =
    let romFS = console.getRomFSDirectory()

    for path in os.walkDirRec(source, relative = true):
        if os.isHidden(path):
            continue

        let (dir, name, extension) = os.splitFile(path)

        let relativePath = fmt("{source}/{path}")
        let destination = fmt("{romFS}/{dir}")

        try:
            os.createDir(destination)

            let destinationPath = fmt("{destination}/{name}")

            if extension in Textures:
                console.runCommand(TextureCommand.format(relativePath,
                        destinationPath))
            elif extension in Fonts:
                console.runCommand(FontCommand.format(relativePath,
                        destinationPath))
            else:
                os.copyFile(relativePath, destination)
        except Exception:
            echo("yeet")

proc publish*(self: Ctr, source: string) =
    let elfBinaryPath = self.getElfBinaryPath()

    if not os.fileExists(elfBinaryPath) and not config.rawData:
        raise newException(Exception, strings.ElfBinaryNotFound.format(
                config.name, self.getConsoleName(), self.getElfBinaryName(),
                config.binSearchPath))

    self.convertFiles(source)
