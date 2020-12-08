#!/usr/bin/env python3

import sys
from argparse import ArgumentParser

import lovebrew.data.config as config
from lovebrew import __description__, __version__


def main(argv=None):
    if not config.run_prompt():
        return

    parser = ArgumentParser("lovebrew", description=__description__)

    parser.add_argument("--version", action="store_true")
    parser.add_argument("-i", "--init", action="store_true")
    parser.add_argument("-c", "--clean", action="store_true")

    args = parser.parse_args()

    if args.init:
        return config.init()
    elif args.version:
        return print(f"{parser.prog} {__version__}")
    elif args.clean:
        return config.clean()

    for target in config.get_targets():
        try:
            target.build()
        except Exception as error:
            print(f"Failed to build for {str(target)}: ({error})")
