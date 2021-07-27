
import console
import ../strings

type
    Ctr* = ref object of ConsoleBase

proc getBinaryExtension*(self: Ctr): string =
    return "3dsx"

proc getConsoleName*(self: Ctr): string =
    return "Nintendo 3DS"

proc getELFBinaryName*(self: Ctr): string =
    return "3DS.elf"

proc getIconExtension*(self: Ctr): string =
    return "png"

proc convertFiles(self: Ctr, source: string) =
    return

proc publish*(self: Ctr, source: string) =
    echo("this works")
    return
