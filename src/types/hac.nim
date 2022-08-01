include console

type
    Hac* = ref object of Console

method getBinaryExtension(this: Hac): string = "nro"
method getConsoleName*(this: Hac): string = "Nintendo Switch"
method getIconExtension(this: Hac): string = "jpg"
method getFileExtensions(this: Hac): array[0x02, string] = [".nro", ".nacp"]

method publish*(this: Hac, cfg: Config): bool =
    logger.info(formatLog(LogData.InitializeBuild, this.getConsoleName()))

    let buildDir = cfg.output.buildDir / cfg.output.gameDir

    # Copy files
    if (not this.convertFiles(cfg.build.source, buildDir)):
        return false

    # Check if the binary exists
    let check = this.checkBinary(cfg.build.searchPath)

    if (not check.exists):
        logger.error(formatError(Error.CompileBinaryNotfound, check.path))
        return false

    let outputName = this.getOutputBinaryName(cfg)

    # Build the zip file
    if (not this.packGameFiles(outputName, buildDir, cfg.output.buildDir)):
        return false

    # Get the icon
    let icon = fmt("{cfg.build.icon}.{this.getIconExtension()}")

    # Set the args for hbupdater
    let args = @[check.path, cfg.metadata.name, cfg.metadata.author, icon,
                 cfg.output.buildDir / fmt("{outputName}.nro")]

    if (not command.run($Command.HacUpdate, args)):
        return false

    # Append the zip file to the nro
    let file = io.open(fmt("{cfg.output.buildDir / outputName}.nro"), fmAppend)
    file.write(io.readFile(fmt("{cfg.output.buildDir / outputName}.love")))

    # Cleanup
    this.clean(cfg.output.buildDir)

    return true
