import os
import subprocess
from pathlib import Path

from ..data.constants import LOGGER, TOP_DIR
from .console import Console


class NX(Console):

    ENV_PATH = Path(os.getenv("DEVKITPRO"))

    NACP_CMD = "nacptool --create {name} {} {} {name}.nacp"
    ELF2NRO_CMD = "elf2nro {} {name}.nro --icon={} --nacp={name}.nacp --romfsdir={romfs}"

    def __init__(self, config):
        super().__init__(config)
        self.elf_binary_path = self.get_elf_binary(NX.name())

    def build(self):
        LOGGER.info("Building for Nintendo Switch..")

        if not self.elf_binary_path.exists():
            raise FileNotFoundError(f"Missing {self.elf_binary_path}?")

        icon_path = self.get_icon(True)

        fmt_cmd = NX.NACP_CMD.format(
            self.author, self.version, name=self.output_directory / self.name)

        try:
            subprocess.run(fmt_cmd, shell=True,
                           check=True, capture_output=True)
        except subprocess.CalledProcessError as error:
            raise Exception(error)

        fmt_cmd = NX.ELF2NRO_CMD.format(self.elf_binary_path, icon_path,
                                        romfs=self.source_directory.name,
                                        name=self.output_directory / self.name)

        try:
            subprocess.run(fmt_cmd, shell=True,
                           check=True, capture_output=True)
        except subprocess.CalledProcessError as error:
            raise Exception(error)

    def __str__(self):
        return NX.name()

    @staticmethod
    def name():
        return "Nintendo Switch"
