import os
import osproc
import strformat

import ../configure
import ../assetsfile

import iface

type
    ConsoleBase* = ref object of RootObj

iface *Console:
    proc getBinaryExtension(): string
    proc getConsoleName(): string
    proc getELFBinaryName(): string
    proc getIconExtension(): string
    proc publish(source: string)

proc getELFBinaryPath*(self: Console): string =
    ## Return the full path to the ELF binary

    return fmt("{config.binSearchPath}/{self.getELFBinaryName()}")

proc getOutputBinaryName*(self: Console): string =
    ## Return the filename with extension (.nro/3dsx)

    return fmt("{config.name}.{self.getBinaryExtension()}")

proc getOutputBinaryPath*(self: Console): string =
    ## Return the full path where the binary is output to

    return fmt("{config.build}/{self.getOutputBinaryName()}")

proc getIcon*(self: Console): string =
    ## Return the full path to the icon
    ## If one isn't found, use the default icon

    var extension = self.getIconExtension()
    let filename = fmt("{config.icon}.{extension}")

    var iconData: string
    if not os.fileExists(filename):
        if extension == "nro":
            iconData = assetsfile.DefaultHacIcon
        else:
            iconData = assetsfile.DefaultCtrIcon

        io.writeFile(filename, iconData)

    return filename

proc runCommand*(command: string) =
    ## Runs a specified command

    let result = execCmdEx(command)
