import console
export console

import tables
import strutils
import strformat
import os

import ../prompts
import ../config

import nimtenbrew
import FreeImage

type
    HAC* = ref object of Console

method getName(self : HAC) : string =
    return "Nintendo Switch"

method publish(self : HAC, source : string) =
    let buildDirectory = self.getBuildDirectory()

    # Create the smdh metadata
    let outputFile = fmt("{buildDirectory}/{self.name.strip()}.nro")

    var outFile = toHacBin(self.getBinary().readFile())

    var nacp = outFile.nacp
    setTitles(nacp, self.name, self.author)

    let jpegBuffer = readFile(self.getIcon())
    outFile.icon = cast[seq[int8]](jpegBuffer)

    writeFile(outputFile, fromHacbin(outfile))

    echo(fmt("Build successful. Please check '{buildDirectory}' for your files."))
