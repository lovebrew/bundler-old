import std/[asyncdispatch, httpclient]
import tables
import strutils
import strformat

import logger

import zippy/ziparchives

const PostUrl = "https://www.bundle.lovebrew.org/"
var dataEndPoint = "/data?title=$title&description=$description&author=$author&version=$version&mode=$mode&app_version=$app_version"

proc asyncProc(endpoint: string, zipFilePath: string,
        iconFilePath: string): Future[AsyncResponse] {.async.} =

    var client = newAsyncHttpClient()
    var data = newMultipartData()

    data.addFiles({"game": zipFilePath})

    if not iconFilePath.isEmptyOrWhitespace:
        data.addFiles({"icon": iconFilePath})

    return await client.post(endpoint, multipart = data)

proc sendData*(mode: string, app_version: string, metadata: Table[string, string],
        gameDir: string): (bool, string, string) =
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
        of "hac":
            extension = "nro"
        of "cafe":
            extension = "wuhb"

    var filename = &"{name}.{extension}"

    try:
        let response = waitFor asyncProc(&"{PostUrl}{copy}", &"{name}.love", metadata["icon"])
        let content = waitFor response.body()

        if response.code() == HttpCode(200):
            return (true, filename, content)
        else:
            return (false, "", content)
    except ValueError as e:
        echo e.msg

    return (false, "", "failed to build")
