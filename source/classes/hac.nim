import console
export console

import tables

import nimtenbrew

type
    HAC* = ref object of Console

method getName(self : HAC) : string =
    return "Nintendo Switch"

method publish(self : HAC, source : string) : bool =
    var outFile = toHacBin(self.getBinary().readFile())

    var nacp = outFile.nacp
    setTitles(nacp, self.name, self.author)

    write(stdout, "Setting nro icon... ")
    let jpegBuffer = readFile(self.getIcon())
    outFile.icon = cast[seq[int8]](jpegBuffer)
    echo("Done!")

    let outputBinary = fromHacbin(outfile)
    return self.packGameDirectory(outputBinary, source)
