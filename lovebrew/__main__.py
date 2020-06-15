#!/usr/bin/env python

__author__ = "TurtleP"
__copyright__ = f"Copyright (c) 2020 {__author__}"
__license__ = "MIT"
__version__ = "0.2.5"

import os
import shutil
from argparse import ArgumentParser

from .console.console import Console
from .console.ctr import CTR
from .console.nx import NX
from .data.config import get_config_data, get_section_item
from .data.constants import (BUILD_FILE_CWD_PATH, DEFAULT_CONFIG_PATH,
                             DEVKITPRO_ERROR, FIRST_RUN_DIALOG, FIRST_RUN_PATH,
                             LOGGER, set_logging)

BUILD_FAILED_STR = "Failed to build for %s (%s)"
TARGET_CLASSES = {"switch": NX, "3ds": CTR}


def has_help_or_version(args):
    result = (hasattr(args, "help") and args.help) or hasattr(
        args, "version") and args.version

    return result


def main(argv=None):
    if not FIRST_RUN_PATH.exists():
        print(FIRST_RUN_DIALOG)
        FIRST_RUN_PATH.touch()

        return

    if not os.getenv("DEVKITARM") or not os.getenv("DEVKITPRO"):
        print(DEVKITPRO_ERROR)
        return

    parser = ArgumentParser(prog='lovebrew',
                            description="Löve Potion Game Helper")

    parser.add_argument("-v", "--verbose", action='store_true',
                        help="Show logging output.")

    parser.add_argument("--version", action='version',
                        version=f"%(prog)s {__version__}")

    parser.add_argument("-c", "--clean", action="store_true",
                        help="Clean the directory")

    parser.add_argument("-i", "--init", action="store_true",
                        help="Initialize a lovebrew config in the current directory")

    args = parser.parse_args()

    if has_help_or_version(args):
        return

    if args.verbose:
        set_logging(True)

    if args.init:
        try:
            if not BUILD_FILE_CWD_PATH.exists():
                shutil.copyfile(DEFAULT_CONFIG_PATH, BUILD_FILE_CWD_PATH)
                print("lovebrew config initialized successfully!")
            else:
                print("lovebrew config already exists. Nothing to do.")
        except Exception as e:
            LOGGER.critical(e)

        return

    if args.clean:
        Console.clean()
        return

    CONFIG = get_config_data()

    # Handle if there's no config or invalid config
    if not CONFIG and CONFIG is not None:
        return LOGGER.critical("Invalid configuration file")
    elif CONFIG is None:
        return LOGGER.critical("No build config file found")

    targets = []

    # get the provided targets, validate them too
    config_targets = get_section_item("build", "targets")
    for target in [x.lower() for x in config_targets]:
        if target not in targets and target in TARGET_CLASSES:
            targets.append(TARGET_CLASSES[target])

    for console in targets:
        try:
            item = console(CONFIG["meta"])

            item.build()

        except Exception as error:
            LOGGER.critical(BUILD_FAILED_STR, console.name(), error)


if __name__ == "__main__":
    main()
