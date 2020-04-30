import os
import subprocess
from pathlib import Path
from zipfile import ZipFile

from ..data.constants import LOGGER, LOVEPOTION_SWITCH
from .console import Console


class NX(Console):

    ENV_PATH = Path(os.getenv("DEVKITPRO"))

    NACP_CMD = 'nacptool --create "{}" "{}" "{}" {}.nacp'
    ELF2NRO_CMD = "elf2nro '{}' '{name}.nro' --icon '{}' --nacp '{name}.nacp" \
                  "--romfsdir=build"
    BUILD_ROMFS_CMD = "build_romfs 'build' '{}.lpx'"

    def __init__(self, config, is_fused):
        super().__init__(config, True)

    def clean(self):
        EXTENSIONS = [".nro", ".nacp"]

        for item in Console.TOP_DIR.iterdir():
            if item.suffix in EXTENSIONS:
                item.unlink()

        super().clean()

    def zip_artifacts(self):
        ARTIFACT = f"{self.name}.nro"

        if not self.is_fused:
            ARTIFACT = super().SRC_DIR
        elif self.is_fused == "lpx":
            ARTIFACT = super().TOP_DIR / f"{self.name}.lpx"

        with ZipFile(f"{self.name}.zip", "w") as zfile:
            zfile.write(ARTIFACT)

    def _build_romfs(self):
        fmt_cmd = NX.BUILD_ROMFS_CMD.format(self.title)

        try:
            subprocess.run(fmt_cmd, shell=True, check=True,
                           capture_output=True)
        except subprocess.CalledProcessError as error:
            raise Exception(error)

    def build(self):
        LOGGER.info("Building for Nintendo Switch..")

        if not LOVEPOTION_SWITCH.exists() and not self.is_fused == "lpx":
            raise FileNotFoundError(f"Missing {LOVEPOTION_SWITCH}?")
        else:
            self._build_romfs()

        icon_path = self.get_icon(True)

        fmt_cmd = NX.NACP_CMD.format(self.name, self.author, self.version)

        try:
            subprocess.run(fmt_cmd, shell=True, check=True,
                           capture_output=True)
        except subprocess.CalledProcessError as error:
            raise Exception(error)

        fmt_cmd = NX.ELF2NRO_CMD.format(LOVEPOTION_SWITCH,
                                        icon_path, name=self.title)

        try:
            subprocess.run(fmt_cmd, shell=True, check=True,
                           capture_output=True)
        except subprocess.CalledProcessError as error:
            raise Exception(error)
