import logging
from pathlib import Path

def set_logging(enable):
    if enable:
        logging.disable(logging.NOTSET)
    else:
        logging.disable(logging.ERROR)

# PATHS & STUFF #

HOME_DIR = Path().home()
BINARIES_DIR = HOME_DIR / ".lovepotion"
TOP_DIR = Path().cwd()

BINARIES_DIR.mkdir(exist_ok=True)

FIRST_RUN_PATH = BINARIES_DIR / ".first_run"
FIRST_RUN_DIALOG = "This software is not endorsed nor maintained by devkitPro.\nIf there are issues, please report them to the GitHub repository:\nhttps://github.com/TurtleP/lovebrew"

DEVKITPRO_ERROR = "Error: Could not find DEVKITARM or DEVKITPRO environment variables.\nPlease follow the wiki for proper setup:\nhttp://TurtleP.github.io/LovePotion/wiki/#"""

DEFAULT_CONFIG_PATH = Path(__file__).parent / "meta/lovebrew.toml"

# DEFAULT ITEM PATHS #

DEFAULT_PATHS = {
    "icon_file":        Path(__file__).parent / "meta/icon",
    "source_directory": TOP_DIR / "game",
    "build_directory":  TOP_DIR / "build",
    "love_directory":   BINARIES_DIR,
    "output_to_build": TOP_DIR
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
set_logging(False)
