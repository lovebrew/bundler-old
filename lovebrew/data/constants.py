import logging
from pathlib import Path

# PATHS & STUFF #

HOME_DIR = Path().home()
BINARIES_DIR = HOME_DIR / ".lovepotion"
TOP_DIR = Path().cwd()

DEFAULT_CONFIG_PATH = Path(__file__).parent / "meta/lovebrew.toml"

# DEFAULT ITEM PATHS #

DEFAULT_PATHS = {
    "icon_file":        Path(__file__).parent / "meta/icon",
    "source_directory": TOP_DIR / "game",
    "build_directory":  TOP_DIR / "build",
    "love_directory":   BINARIES_DIR
}

BUILD_FILE_NAME = "lovebrew.toml"
BUILD_FILE_CWD_PATH = TOP_DIR / BUILD_FILE_NAME

# LOGGER STUFF #

BUILD_LOG_FORMAT = "[%(asctime)s] / %(levelname)s / %(message)s"
BUILD_LOG_FILENAME = TOP_DIR / "build.log"

# LOGGER OBJECT #

LOGGER = logging.getLogger("build")

_formatter = logging.Formatter(BUILD_LOG_FORMAT, "%Y-%m-%d %H:%M:%S")

_handler = logging.StreamHandler()
_handler.setLevel(logging.INFO)
_handler.setFormatter(_formatter)
LOGGER.setLevel(logging.INFO)

LOGGER.addHandler(_handler)
