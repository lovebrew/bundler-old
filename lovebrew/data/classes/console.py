import subprocess
from pathlib import Path


class Console:

    def __init__(self, data):

        # Not verbose, but ¯\_(ツ)_/¯
        for key, value in data.items():
            setattr(self, key, value)

        self.output_directory = Path("")

        if self.output_to_build:
            self.output_directory = self.build_directory

    def _run_command(self, command):
        """
            Runs the specified @command
        """

        try:
            subprocess.run(command, capture_output=True, check=True, shell=True, universal_newlines=True)
        except subprocess.CalledProcessError as error:
            raise Exception(error)

    def get_icon(self):
        suffix = ".png"

        if "Switch" in str(self):
            suffix = ".jpg"

        return self.icon_file.with_suffix(suffix)

    def get_binary(self):
        name = "3ds"

        if "Switch" in str(self):
            name = "switch"

        return (self.love_directory / name).with_suffix(".elf")

    def build(self):
        if not self.get_binary().exists():
            raise FileNotFoundError(f"Missing {self.get_binary()}?")
