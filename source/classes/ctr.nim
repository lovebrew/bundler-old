import console
export console

import tables
import strutils
import strformat
import os
import bitops
import lenientops
import system
import times

import ../prompts
import ../config

import nimtenbrew
import nimPNG
import flatty/binny
import zippy

## Command line stuff to run
var COMMANDS : Table[string, string]

COMMANDS["texture"] = "tex3ds $1 --format=rgba8888 -z auto -o $2.t3x"
COMMANDS["font"]    = "mkbcfnt $1 -o $2.bcfnt"

## Applicable conversions n such
let textures = @[".png", ".jpg", ".jpeg"]
let fonts    = @[".ttf", ".otf"]

type
    CTR* = ref object of Console

{.push base.}

method convertFiles*(self : CTR, source : string) =
    write(stdout, "Converting and copying files.. please wait.. ")
    flushFile(stdout)

    let start = getTime()

    # Get our important directories
    let romFSDirectory = self.getRomFSDirectory()

    # Ensure the required ELF binary exists. If it doesn't, we should abort and inform the user.
    # This should only be an issue if compiling non-raw builds
    let binaryFull = self.getBinary()

    if not binaryFull.fileExists() and not config.getOutputValue("raw").getBool():
        showPromptFormatted("BUILD_FAIL", source, self.getName(), self.getBinaryName(), self.getBinaryPath())
        return

    # Walk through the source directory
    for path in walkDirRec(source, relative = true):
        let (dir, name, extension) = splitFile(path)

        let relativePath = fmt("{source}/{path}")
        let destination = fmt("{romFSDirectory}/{dir}")

        # May or may not be horribly inefficient because it attempt to create all directories
        # for pretty much every file multiple times, but it shouldn't be *that* bad
        createDir(destination)

        # If the file we're currently looking at has its extension in one of these sets, operate on it
        # See the COMMANDS table for more information
        if extension in textures:
            self.runCommand(COMMANDS["texture"].format(relativePath, fmt("{destination}/{name}")))
        elif extension in fonts:
            self.runCommand(COMMANDS["font"].format(relativePath, fmt("{destination}/{name}")))
        else:
            copyFile(relativePath, fmt("{destination}/{name}{extension}"))

    let delta = (getTime() - start).inSeconds()
    echo(fmt("done in {delta}s"))

method convertARGBToRGB565(self : CTR, a, r, g, b : var uint8) : uint16 =
    r = (1.0 * r * a / 255.0).uint8
    g = (1.0 * g * a / 255.0).uint8
    b = (1.0 * b * a / 255.0).uint8

    r = (r shr 3)
    g = (g shr 2)
    b = (b shr 3)

    r = (r shl 11)
    g = (g shl 5)

    return bitor(r, g, b).uint16

method blendColor(self: CTR, a, b, c, d : uint8) : uint8 =
    var x : uint8

    x += a
    x += b
    x += c
    x += d

    return (x + 2) div 4

method createAndSetIcon(self : CTR, outFile : var Ctrbin) =
    write(stdout, "Setting 3dsx icon.. please wait.. ")
    flushFile(stdout)

    let start = getTime()

    let largeImage = nimPNG.loadPNG32(self.getIcon())
    var bitmap = largeImage.data

    let tileOrder = @[0, 1, 8, 9, 2, 3, 10, 11, 16, 17, 24, 25, 18, 19, 26, 27,
                      4, 5, 12, 13, 6, 7, 14, 15, 20, 21, 28, 29, 22, 23, 30, 31,
                      32, 33, 40, 41, 34, 35, 42, 43, 48, 49, 56, 57, 50, 51, 58, 59,
                      36, 37, 44, 45, 38, 39, 46, 47, 52, 53, 60, 61, 54, 55, 62, 63]

    var largeIcon = newSeq[uint16](48 * 48)
    var smallIcon = newSeq[uint16](24 * 24)

    # Create the large icon

    iterator countTo(n : int, step : int) : int =
        var i = 0
        while i < n:
            yield i
            i += step

    proc bswap16(n : uint16) : uint16 =
        if cpuEndian != littleEndian:
            return swap(n)

        return n

    var index = 0

    for y in countTo(48, 8):
        for x in countTo(48, 8):
            for k in countTo(8 * 8, 1):
                let xx = bitand(tileOrder[k], 0x7)
                let yy = (tileOrder[k] shr 3)

                let rgba = cast[ptr UncheckedArray[uint8]](addr(bitmap[4 * (48 * (y + yy) + (x + xx))]))

                var r = rgba[0]
                var g = rgba[1]
                var b = rgba[2]
                var a = rgba[3]

                largeIcon[index] = bswap16(self.convertARGBToRGB565(a, r, g, b))
                inc index

    index = 0

    let smallImage = nimPNG.loadPNG32(self.getIcon())
    bitmap = smallImage.data

    for y in countTo(24, 8):
        for x in countTo(24, 8):
            for k in countTo(8 * 8, 1):
                let xx = bitand(tileOrder[k], 0x7)
                let yy = (tileOrder[k] shr 3)

                let rgba0 = cast[ptr UncheckedArray[uint8]](addr(bitmap[4 * (48 * 2 * (y + yy) + 2 * (x + xx))]))
                let rgba1 = cast[ptr UncheckedArray[uint8]](addr(bitmap[4 * (48 * 2 * (y + yy) + 2 * (x + xx))]))

                let rgba2 = cast[ptr UncheckedArray[uint8]](addr(bitmap[4 * (48 * (2 * (y + yy) + 1) + 2 * (x + xx) + 1)]))
                let rgba3 = cast[ptr UncheckedArray[uint8]](addr(bitmap[4 * (48 * (2 * (y + yy) + 1) + 2 * (x + xx) + 1)]))

                var r = self.blendColor(rgba0[0], rgba1[0], rgba2[0], rgba3[0])
                var g = self.blendColor(rgba0[1], rgba1[1], rgba2[1], rgba3[1])
                var b = self.blendColor(rgba0[2], rgba1[2], rgba2[2], rgba3[2])
                var a = self.blendColor(rgba0[3], rgba1[3], rgba2[3], rgba3[3])

                smallIcon[index] = bswap16(self.convertARGBToRGB565(a, r, g, b))
                inc index

    outfile.smallIcon = smallIcon
    outfile.largeIcon = largeIcon

    let delta = (getTime() - start).inSeconds()
    echo(fmt("done in {delta}s"))

{.pop base}

method publish(self : CTR, source : string) =
    let buildDirectory = self.getBuildDirectory()
    self.convertFiles(source)

    # If we're building in "raw" mode, don't create a 3dsx
    if config.getOutputValue("raw").getBool():
        return

    # Create the smdh metadata
    let outputFile = fmt("{buildDirectory}/{self.name.strip()}.3dsx")
    let properDescription = fmt("{self.description} • {self.version}")

    var outfile = toCTRBin(self.getBinary().readFile())
    setTitles(outfile, self.name, properDescription, self.author)

    self.createAndSetIcon(outFile)

    writeFile(outputFile, fromCtrbin(outfile))

    echo(fmt("Build successful. Please check '{buildDirectory}' for your files."))

method getName(self : CTR) : string =
    return "Nintendo 3DS"
