import os
from pathlib import Path

from .console import Console


class HAC(Console):

    ENV_PATH = Path(os.getenv("DEVKITPRO"))

    COMMANDS = {
        "meta": "nacptool --create '{name}' '{author}' '{version}' {dst}.nacp",
        "binary": "elf2nro {elf} {dst}.nro --icon={icon} --nacp={dst}.nacp --romfsdir={romfs}"
    }

    def __init__(self, data):
        super().__init__(data)

    def build(self):
        super().build()

        self.build_directory.mkdir(exist_ok=True)

        command = HAC.COMMANDS["meta"].format(name=self.name,
                                              author=self.author,
                                              version=self.version,
                                              dst=self.output_directory / self.target_name.name)

        self._run_command(command)

        command = HAC.COMMANDS["binary"].format(elf=self.get_binary(),
                                                icon=self.get_icon(),
                                                dst=self.output_directory / self.target_name.name,
                                                romfs=self.source_directory.name)

        self._run_command(command)

    def __str__(self):
        return "Nintendo Switch"
