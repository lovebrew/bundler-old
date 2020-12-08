import os
import pprint
import shutil
from pathlib import Path

import toml

from lovebrew.data import DEVKITARM_DIALOG, DEVKITPRO_DIALOG, RUN_DIALOG

from .classes.ctr import CTR
from .classes.hac import HAC

PATH = Path(__file__).parent
BASE_CONFIG = PATH / "meta/lovebrew.toml"

DEFAULT_PATHS = {
    "icon_file": PATH / "meta/icon",
    "love_directory": PATH / Path.home() / ".lovepotion",
    "build_directory": Path("build"),
    "target_name": Path.cwd()
}

FIRST_RUN_FILE = DEFAULT_PATHS["love_directory"] / ".first_run"

base = None
with open(BASE_CONFIG, "r") as file:
    base = toml.loads(file.read())

TOP_DIR = Path.cwd()
USER_CONFIG = Path("lovebrew.toml")


def run_prompt():
    """
        Displays the 'First Run Dialog' if this is the first time running.
        Otherwise, will error if it cannot find the proper environment variables.
    """

    if FIRST_RUN_FILE.exists():
        if os.getenv("DEVKITPRO"):
            if os.getenv("DEVKITARM"):
                return True
            else:
                return print(DEVKITARM_DIALOG)
        else:
            return print(DEVKITPRO_DIALOG)
    else:
        FIRST_RUN_FILE.touch()
        return print(RUN_DIALOG)


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
                    if type(value) is str:
                        base["build"][key] = Path(value)
                    else:
                        base["build"][key] = value

            return base
    except FileNotFoundError:
        print("Config not found. Try creating one with --init.")


def get_data():
    out = {**base["meta"], **base["build"]}

    return out


def get_targets():
    out = []

    target_consoles = {
        "3ds": CTR,
        "switch": HAC
    }

    meta_data = get_data()
    targets = [x.lower() for x in base["build"]["targets"]]

    if base["pre_hook"]["clean"]:
        clean()

    for item in targets:
        if item in target_consoles:
            out.append(target_consoles[item](meta_data))

    return out


def init():
    """
        Initialize a fresh config to the current directory.
        Will not overwite if it already exists.
    """

    try:
        if USER_CONFIG.exists():
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
    except:
        pass

    for item in TOP_DIR.glob("**/*"):
        if item.suffix in search:
            item.unlink()

load()
