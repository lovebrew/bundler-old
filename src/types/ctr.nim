include console

type
    Ctr* = ref object of Console

method getBinaryExtension(this: Ctr): string = "3dsx"
method getConsoleName*(this: Ctr): string = "Nintendo 3DS"
method getIconExtension(this: Ctr): string = "png"
method getFileExtensions(this: Ctr): array[0x02, string] = [".3dsx", ".smdh"]

method publish*(this: Ctr, cfg: Config): bool =
    logger.info(formatLog(LogData.InitializeBuild, this.getConsoleName()))

    let buildDir = cfg.output.buildDir / cfg.output.gameDir

    # Convert and/or copy files
    if (not this.convertFiles(cfg.build.source, buildDir, convert = true)):
        return false

    # Check if the binary exists and if we want only converted files
    let check = this.checkBinary(cfg.build.searchPath)

    if (not check.exists and not cfg.output.noBinary):
        logger.error(formatError(Error.CompileBinaryNotfound, check.path))
        return false

    # Build the zip file
    let outputName = this.getOutputBinaryName(cfg)

    if (not this.packGameFiles(outputName, buildDir, cfg.output.buildDir)):
        return false

    # Get the icon path
    let icon = fmt("{cfg.build.icon}.{this.getIconExtension()}")

    # Create our description Sequence
    let description = @[cfg.metadata.description, cfg.metadata.version]

    # set the args for hbupdater
    let newDescription = this.getDescription(description)

    let args = @[check.path, cfg.metadata.name, cfg.metadata.author,
                 icon, newDescription, cfg.output.buildDir / outputName]

    if (not command.run($Command.CtrUpdate, args)):
        return false

    # Append the zip file to the 3dsx
    let gameContent = io.readFile(fmt("{cfg.output.buildDir / outputName}.love"))

    let output = io.open(fmt("{cfg.output.buildDir / outputName}.3dsx"), fmAppend)
    output.write(gameContent)

    # Cleanup
    this.clean(cfg.output.buildDir)

    return true
