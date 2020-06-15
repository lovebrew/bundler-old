from pathlib import Path

import toml

from .constants import (BUILD_FILE_CWD_PATH, DEFAULT_CONFIG_PATH,
                        DEFAULT_PATHS, LOGGER, TOP_DIR)

DEFAULT_CONFIG = None
with open(DEFAULT_CONFIG_PATH, "r") as file:
    DEFAULT_CONFIG = toml.loads(file.read())


def key_exists(key, exists):
    """
        Validates @key in DEFAULT_CONFIG\n
        Returns the result and output for @exists
    """

    result = key in DEFAULT_CONFIG

    if not result:
        keys_list = list(DEFAULT_CONFIG.keys())
        LOGGER.error("Invalid config key '%s'. Expected one of: "
                     f"{', '.join(keys_list)}", key)

    exists = result

    return exists


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
        DEFAULT_CONFIG.update(user_config["meta"], {"name": TOP_DIR.stem})

    return DEFAULT_CONFIG


def get_config_data():
    """
        Gets the config file's data\n
        Returns a dict on success, None or False on failure
    """

    if BUILD_FILE_CWD_PATH.exists():
        is_valid = True

        with open(BUILD_FILE_CWD_PATH, "r") as file:
            toml_string = file.read()

            try:
                loaded_string = toml.loads(toml_string)

                for key in loaded_string:
                    if not key_exists(key, is_valid):
                        break

                if is_valid:
                    return update_config(loaded_string)

                return False
            except toml.TomlDecodeError as e:
                LOGGER.error(str(e))

    LOGGER.debug(f"No build config found.")
    return None
