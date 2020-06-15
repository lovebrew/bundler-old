from pathlib import Path

import toml

from .constants import (BUILD_FILE_CWD_PATH, DEFAULT_CONFIG_PATH,
                        DEFAULT_PATHS, LOGGER, TOP_DIR)

DEFAULT_CONFIG = None
with open(DEFAULT_CONFIG_PATH, "r") as file:
    DEFAULT_CONFIG = toml.loads(file.read())


def get_section_item(name, item=None):
    if name in DEFAULT_CONFIG:
        if not item:
            return DEFAULT_CONFIG[name]
        else:
            if item in DEFAULT_CONFIG[name]:
                return DEFAULT_CONFIG[name][item]

    return None


def get_item_path(item):
    """
        Checks for the CONFIG item first.\n
        If not found, use the DEFAULT
    """
    build_item = DEFAULT_CONFIG["build"][item]
    if type(build_item) is str and build_item:
        local_path = TOP_DIR / build_item

        return local_path

    return DEFAULT_PATHS[item]


def update_config(user_config):
    DEFAULT_CONFIG.update(user_config)

    if "name" not in user_config["meta"]:
        LOGGER.info("No 'name' provided. Using Directory name.")
        DEFAULT_CONFIG["meta"].update({"name": TOP_DIR.stem})

    if DEFAULT_CONFIG["build"]["output_to_build"]:
        DEFAULT_CONFIG["build"].update({"output_to_build": get_item_path("build_directory").name})

    return DEFAULT_CONFIG


def get_config_data():
    """
        Gets the config file's data\n
        Returns a dict on success, None or False on failure
    """

    if BUILD_FILE_CWD_PATH.exists():
        with open(BUILD_FILE_CWD_PATH, "r") as file:
            toml_string = file.read()

            try:
                loaded_config = toml.loads(toml_string)

                if "meta" in loaded_config and "build" in loaded_config:
                    return update_config(loaded_config)

                return False
            except toml.TomlDecodeError as e:
                LOGGER.error(str(e))

    LOGGER.critica("No build config found. Run lovebrew --init to create one.")
    return None
