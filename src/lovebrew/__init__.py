import importlib.metadata
from argparse import ArgumentParser

import requests

from lovebrew.config import Config

_DISTRIBUTION_METADATA = importlib.metadata.metadata("lovebrew")

_APP_NAME = _DISTRIBUTION_METADATA["name"]
_APP_VERSION = _DISTRIBUTION_METADATA["version"]
_APP_DESCRIPTION = _DISTRIBUTION_METADATA["description"]


def init():
    if Config.exists():
        result = input("Config exists. Overwrite? [y/N]: ")

        if result.lower() != "y":
            return

    Config.create()


def build():
    config = Config()

    response = requests.post("https://www.bundle.lovebrew.org/")
    print(response.content, response.status_code)


def main():
    parser = ArgumentParser("lovebrew", description=_APP_DESCRIPTION)

    parser.add_argument("-init", "-i", help="create a new config", action="store_true")
    parser.add_argument("-build", "-b", help="build a project", action="store_true")

    parser.add_argument(
        "--version", action="version", version=f"{_APP_NAME} {_APP_VERSION}"
    )

    parsed_arguments = parser.parse_args()

    if "version" in parsed_arguments:
        return

    if parsed_arguments.init:
        init()
    elif parsed_arguments.build:
        build()
