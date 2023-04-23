import std/[asyncdispatch, httpclient]
import tables
import strutils
import strformat
import os

import logger

import zippy/ziparchives

const PostUrl = "https://www.bundle.lovebrew.org/"
var dataEndPoint = "/data?title=$title&description=$description&author=$author&version=$version&mode=$mode"

proc asyncProc(filename: string, endpoint: string, zipFilePath: string): Future[string] {.async.} =
    var client = newHttpClient()

    var data = newMultipartData()
    data.addFiles({"game": zipFilePath})

    let response = client.post(endpoint, multipart = data)

    if response.code == HttpCode(200):
        io.writeFile(filename, response.body)

proc sendData*(mode: string, metadata: Table[string, string], gameDir: string) =
    var copy = dataEndPoint
    for key, value in metadata.pairs():
        copy = copy.replace(&"${key}", value)

    copy = copy.replace("$mode", mode)
    var name = metadata["title"]

    try:
        logger.info(&"Zipping {gameDir} to {name}.love")
        ziparchives.createZipArchive(&"{gameDir}/", &"{name}.love")
    except Exception as e:
        logger.error(e.msg)
        return

    var extension = "3dsx"
    case mode:
        of "switch":
            extension = "nro"
        of "wiiu":
            extension = "wuhb"

    var filename = &"{name}.{extension}"

    discard waitFor asyncProc(filename, &"{PostUrl}{copy}", &"{name}.love")
    os.removeFile(&"{name}.love")
