import shutil
from pathlib import Path

from ..data.constants import DEFAULT_ICON_PATH, LOGGER


class Console:

    SRC_DIR = Path().cwd() / "game"
    BUILD_DIR = Path().cwd() / "build"
    TOP_DIR = Path().cwd()

    ICON = Path().cwd() / "icon"

    def __init__(self, config, is_fused):
        self.is_fused = is_fused

        self.__dict__.update(config)

    def clean(self):
        shutil.rmtree(Console.BUILD_DIR)

    def get_icon(self, is_nx=False):
        """
            Retrieve the icon path for the console.\n
            If @is_nx is True, it's the Switch icon.
        """

        ext = ".png"

        if is_nx:
            ext = ".jpg"

        if not Path(str(Console.ICON) + ext).exists():
            LOGGER.warning("No icon was provided. Using default.")
            return str(DEFAULT_ICON_PATH) + ext

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
