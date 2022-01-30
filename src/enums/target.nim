import strutils

type
    Target* = enum
        TARGET_HAC = "switch", TARGET_CTR = "3ds"

proc isValid*(value: string): bool =
    case value:
        of $TARGET_CTR:
            return true
        of $TARGET_HAC:
            return true

    return false

proc asEnum*(value: string): Target =
    if isValid(value):
        return parseEnum[Target](value)
