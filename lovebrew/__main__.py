__author__ = "TurtleP"
__copyright__ = f"Copyright (c) 2020 {__author__}"
__license__ = "MIT"
__version__ = "0.1.0"

from argparse import ArgumentParser

from .console.ctr import CTR
from .console.nx import NX
from .data.config import get_config_data
from .data.constants import LOGGER

BUILD_FAILED_STR = "Failed to build for %s (%s)"
TARGET_CLASSES = {"switch": NX, "3ds": CTR}


def has_help_or_version(args):
    result = (hasattr(args, "help") and args.help) or hasattr(
        args, "version") and args.version

    return result


def handle_post_build(cfg, item):
    zip_options = cfg["zip"]

    if zip_options:
        item.zip_artifacts()

        if zip_options["build_clean"]:
            item.clean()


def main(argv=None):
    parser = ArgumentParser(prog='lovebrew',
                            description="Löve Potion Game Helper")

    parser.add_argument("-v", "--verbose", action='store_true',
                        help="Show logging output.")

    parser.add_argument("-f", "--fused",
                        help="Create a fused game. Pass 'lpx' "
                        "to only create the romfs (Switch Only)")

    parser.add_argument("--version", action='version',
                        version=f"%(prog)s {__version__}")

    parser.add_argument("-c", "--clean", action='store_true',
                        help="Clean the directory")

    args = parser.parse_args()

    if has_help_or_version(args):
        return

    if not args.verbose:
        LOGGER.disabled = True

    CONFIG = get_config_data()

    targets = []

    # get the provided targets, validate them too
    for target in [x.lower() for x in CONFIG["targets"]]:
        if target not in targets and target in TARGET_CLASSES:
            targets.append(TARGET_CLASSES[target])

    for console in targets:
        try:
            item = console(CONFIG, args.fused)

            if args.clean:
                return item.clean()

            item.build()

            handle_post_build(CONFIG["artifacts"], item)

        except Exception as error:
            LOGGER.critical(BUILD_FAILED_STR, console.name(), error)


if __name__ == "__main__":
    main()
