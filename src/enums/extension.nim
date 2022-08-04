import os

type
    Extension* = enum
        T3x = "t3x"
        Bcfnt = "bcfnt"
        Other = "other"

proc fromExtension*(filename: string): Extension =
    let (_, _, extension) = os.splitFile(filename)

    case extension
        of ".png", ".jpg", ".jpeg":
            return Extension.T3x
        of ".ttf", ".otf":
            return Extension.Bcfnt
        else:
            return Extension.Other

proc replace*(filename: string): string =
    if (let a = fromExtension(filename); a != Extension.Other):
        return os.changeFileExt(filename, $a)

    return filename
