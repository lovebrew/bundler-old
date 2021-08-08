
import strformat

type
    BrewException* = ref object of CatchableError

proc RefBrewException(message : string) : BrewException =
    let reference = BrewException()
    reference.msg = message

    return reference

proc BinaryExecutionException*(exec, message : string) : BrewException =
    return RefBrewException(fmt("Failed to execute {exec}! Error: {message}"))

proc TextureConversionException*(message : string) : BrewException =
    return RefBrewException(fmt("[tex3ds] Conversion Error: {message}"))

proc FontConversionException*(message : string) : BrewException =
    return RefBrewException(fmt("[mkbcfnt] Conversion Error: {message}"))
