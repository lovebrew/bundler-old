import std/[asyncdispatch, httpclient]
import tables
import strutils
import strformat
import os

import logger

import zippy/ziparchives

const PostUrl = "https://www.bundle.lovebrew.org/"
var dataEndPoint = "/data?title=$title&description=$description&author=$author&version=$version&mode=$mode&app_version=$app_version"

proc asyncProc(filename: string, endpoint: string, zipFilePath: string,
        iconFilePath: string): Future[string] {.async.} =
    var client = newHttpClient()

    var data = newMultipartData()

    data.addFiles({"game": zipFilePath})
    data.addFiles({"icon": iconFilePath})

    let response = client.post(endpoint, multipart = data)

    if response.code == HttpCode(200):
        io.writeFile(filename, response.body)

proc sendData*(mode: string, app_version: string, metadata: Table[string, string],
        gameDir: string) =
    var copy = dataEndPoint
    for key, value in metadata.pairs():
        copy = copy.replace(&"${key}", value)

    copy = copy.replace("$mode", mode)
    copy = copy.replace("$app_version", app_version)

    var name = metadata["title"]

    try:
        logger.info(&"Zipping {gameDir} to {name}.love")
        ziparchives.createZipArchive(&"{gameDir}/", &"{name}.love")
    except ZippyError as e:
        logger.error(e.msg)
        return

    var extension = "3dsx"
    case mode:
        of "switch":
            extension = "nro"
        of "wiiu":
            extension = "wuhb"

    var filename = &"{name}.{extension}"

    discard waitFor asyncProc(filename, &"{PostUrl}{copy}", &"{name}.love", metadata["icon"])
    os.removeFile(&"{name}.love")
