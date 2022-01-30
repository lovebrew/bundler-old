type
    Extension* = enum
        T3X = "t3x", BCFNT = "bcfnt", OTHER = "other"

const TextureExtensions = @[".png", ".jpg", ".jpeg"]
const FontExtensions = @[".ttf", ".otf"]

proc getExtension*(fileExt: string): Extension =
    if fileExt in TextureExtensions:
        return T3X
    elif fileExt in FontExtensions:
        return BCFNT
    else:
        return OTHER
