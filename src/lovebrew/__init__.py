import importlib.metadata
from argparse import ArgumentParser

import requests

from lovebrew import client
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


def build(app_version: int) -> None:
    config = Config()

    for target in config["build"]["targets"]:
        (success, filename, content) = client.send_data(config, target, app_version)

        if not success:
            print(content)
        else:
            with open(f"{config['build']['saveDir']}/{filename}", "wb") as file:
                file.write(content)

            print(f"Build for {target.upper()} successful.")


def main() -> None:
    parser = ArgumentParser("lovebrew", description=_APP_DESCRIPTION)

    parser.add_argument("-init", "-i", help="create a new config", action="store_true")
    parser.add_argument(
        "-build",
        "-b",
        nargs="?",
        const=2,
        metavar=("APP_VERSION"),
        help="build a project",
        type=int,
    )

    parser.add_argument(
        "--version", action="version", version=f"{_APP_NAME} {_APP_VERSION}"
    )

    parsed_arguments = parser.parse_args()

    if "version" in parsed_arguments:
        return

    if parsed_arguments.init:
        init()
    elif parsed_arguments.build:
        build(parsed_arguments.build)
