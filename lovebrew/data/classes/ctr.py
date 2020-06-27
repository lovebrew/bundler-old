import os
import shutil
import subprocess
from pathlib import Path

from .console import Console


class CTR(Console):

    ENV_PATH = Path(os.getenv("DEVKITARM"))

    TEXTURE_EXTENSIONS = [".png", ".jpg", ".jpeg"]
    FONT_EXTENSIONS = [".ttf", ".otf"]
    SOURCE_EXTENSIONS = [".lua", ".t3x", ".bcfnt"]

    COMMANDS = {
        "texture": "tex3ds {src} --format=rgba8888 -z auto -o {dst}",
        "font": "mkbcfnt {src} -o {dst}",
        "meta": "smdhtool --create '{name}' '{desc}' '{author}' {icon} {dst}.smdh",
        "binary": "3dsxtool {elf} {dst}.3dsx --smdh={dst}.smdh --romfs={romfs}"
    }

    def __init__(self, data):
        super().__init__(data)
        self.build()

    def _get_destination_path(self, filepath, ext):
        """
            Gets the destination path for @filepath, adding @ext to the end
        """

        destination = self.build_directory / filepath.with_suffix(ext)
        destination.parent.mkdir(parents=True, exist_ok=True)

        return destination

    def _convert_texture(self, filepath):
        destination = self._get_destination_path(filepath, ".t3x")

        command = CTR.COMMANDS["texture"].format(src=filepath,
                                                 dst=destination)

        self._run_command(command)

    def _convert_font(self, filepath):
        destination = self._get_destination_path(filepath, ".bcfnt")

        command = CTR.COMMANDS["font"].format(src=filepath,
                                              dst=destination)

        self._run_command(command)

    def _copy_file(self, filepath):
        destination = self._get_destination_path(filepath, filepath.suffix)

        try:
            shutil.copy2(filepath, destination)
        except Exception as error:
            print(error)

    def _finalize(self):
        command = CTR.COMMANDS["meta"].format(name=self.name,
                                              author=self.author,
                                              desc=self.description,
                                              icon=self.get_icon(),
                                              dst=self.output_directory / self.name)

        self._run_command(command)

        command = CTR.COMMANDS["binary"].format(elf=self.get_binary(),
                                                name=self.name,
                                                dst=self.output_directory / self.name,
                                                romfs=self.build_directory / self.source_directory.name)

        self._run_command(command)

    def build(self):
        super().build()

        for file in self.source_directory.rglob("*"):
            if file.suffix in CTR.TEXTURE_EXTENSIONS:
                self._convert_texture(file)
            elif file.suffix in CTR.FONT_EXTENSIONS:
                self._convert_font(file)
            elif file.suffix in CTR.SOURCE_EXTENSIONS:
                self._copy_file(file)

        self._finalize()

    def __str__(self):
        return "Nintendo 3DS"
