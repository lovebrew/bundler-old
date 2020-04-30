from pathlib import Path
import logging

# PATHS & STUFF #

BINARIES_DIR = ".lovepotion"
TOP_DIR = Path().cwd()

LOVEPOTION_3DS = Path().home() / BINARIES_DIR / "3ds.elf"
LOVEPOTION_SWITCH = Path().home() / BINARIES_DIR / "switch.elf"

DEFAULT_ICON_PATH = Path(__file__).parent / "icons/icon"

BUILD_FILE_NAME = "lovebrew.toml"
BUILD_FILE_CWD_PATH = Path().cwd() / BUILD_FILE_NAME

# LOGGER STUFF #

BUILD_LOG_FORMAT = "[%(asctime)s] / %(levelname)s / %(message)s"
BUILD_LOG_FILENAME = TOP_DIR / "build.log"

# LOGGER OBJECT #

LOGGER = logging.getLogger("build")

_formatter = logging.Formatter(BUILD_LOG_FORMAT, "%Y-%m-%d %H:%M:%S")

_handler = logging.StreamHandler()
_handler.setLevel(logging.INFO)
_handler.setFormatter(_formatter)

LOGGER.addHandler(_handler)
