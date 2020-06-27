import os
import pprint
import shutil
from pathlib import Path

import toml

from lovebrew.data import RUN_DIALOG, DEVKITARM_DIALOG, DEVKITPRO_DIALOG

PATH = Path(__file__).parent
BASE_CONFIG = PATH / "meta/lovebrew.toml"

DEFAULT_PATHS = {
    "icon_file": PATH / "meta/icon",
    "love_directory": PATH / Path.home() / ".lovepotion",
    "build_directory": "build"
}

FIRST_RUN_FILE = DEFAULT_PATHS["love_directory"] / ".first_run"

base = None
with open(BASE_CONFIG, "r") as file:
    base = toml.loads(file.read())

TOP_DIR = Path.cwd()


def run_prompt():
    """
        Displays the 'First Run Dialog' if this is the first time running.
        Otherwise, will error if it cannot find the proper environment variables.
    """

    if not FIRST_RUN_FILE.exists():
        FIRST_RUN_FILE.touch()
        return print(RUN_DIALOG)

    if not os.getenv("DEVKITPRO"):
        return print(DEVKITPRO_DIALOG)

    if not os.getenv("DEVKITARM"):
        return print(DEVKITARM_DIALOG)

    return True


def load():
    """
        Loads the user-defined config values.
    """

    try:
        # Update the build section with defaults
        base["build"].update(DEFAULT_PATHS)

        with open("lovebrew.toml", "r") as file:
            new_base = toml.loads(file.read())

            # Unconditionally update meta section
            base["meta"].update(new_base["meta"])

            # Update build section key/value if it's not false
            for key, value in new_base["build"].items():
                if value:
                    base["build"][key] = value

            return base
    except FileNotFoundError:
        print("Config not found. Try creating one with --init.")


def init():
    """
        Initialize a fresh config to the current directory.
        Will not overwite if it already exists.
    """

    try:
        if BASE_CONFIG.exists():
            return print("Config already exists. Nothing to do.")

        shutil.copy2(BASE_CONFIG, TOP_DIR)
    except Exception as e:
        print(e)


def clean():
    """
        Cleans the configured build directory.
        Removes 3dsx, smdh, nro, and nacp files.
    """

    search = [".3dsx", ".smdh",
              ".nro", ".nacp"]

    try:
        shutil.rmtree(base["build"]["build_directory"])
    except Exception as e:
        print(e)

    for item in TOP_DIR.glob("**/*"):
        if item.suffix in search:
            item.unlink()
