import toml

from .constants import BUILD_FILE_CWD_PATH, LOGGER, TOP_DIR

DEFAULT_CONFIG = {
    "author": "SuperAuthor",
    "description": "SuperDescription",
    "name": "SuperGame",
    "targets": ["3ds", "switch"],
    "version": "0.0.0",
    "zip_artifacts": True
}


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


def update_config(user_config):
    DEFAULT_CONFIG.update(user_config)

    if "name" not in user_config:
        LOGGER.info("No 'name' provided. Using Directory name.")
        DEFAULT_CONFIG.update({"name": TOP_DIR.stem})

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
