import shutil
from pathlib import Path

from ..data.config import get_item_path
from ..data.constants import LOGGER, TOP_DIR


class Console:

    def __init__(self, config):
        self.__dict__.update(config)

        self.build_directory = get_item_path("build_directory")
        self.source_directory = get_item_path("source_directory")

    def clean(self):
        shutil.rmtree(self.build_directory)

    def get_icon(self, is_nx=False):
        """
            Retrieve the icon path for the console.\n
            If @is_nx is True, it's the Switch icon.
        """

        ext = ".png"

        if is_nx:
            ext = ".jpg"

        icon_path = get_item_path("icon_file")

        return icon_path.with_suffix(ext)

    def get_elf_binary(self, which):
        directory = get_item_path("love_directory")

        if "3DS" in which:
            directory /= "3ds"
        else:
            directory /= "switch"

        return directory.with_suffix(".elf")

    def build_love_game(self):
        ARTIFACT = self.build_directory / self.source_directory

        shutil.make_archive(self.name, 'zip', ARTIFACT)
        shutil.move(f"{self.name}.zip", f"{self.name}.love")

    def build_meta(self):
        """
            Builds the meta file for the console.\n
            On 3DS it's the smdh; Switch nacp.\n
            This must be implemented in the subclass.
        """

        raise NotImplementedError

    def build(self):
        """
            Perform generic build operations.\n
            This must be implemented in the subclass.
        """

        raise NotImplementedError
