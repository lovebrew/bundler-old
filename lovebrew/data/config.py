import shutil
from pathlib import Path

import toml


PATH = Path(__file__).parent
BASE_CONFIG = PATH / "meta/lovebrew.toml"

DEFAULT_PATHS = {
    "icon_file": PATH / "meta/icon",
    "love_directory": PATH / Path.home() / ".lovepotion",
    "build_directory": "build"
}

base = None
with open(BASE_CONFIG, "r") as file:
    base = toml.loads(file.read())

TOP_DIR = Path.cwd()

def load():
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
