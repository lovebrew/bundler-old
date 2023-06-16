import importlib.resources as resources
import pkgutil
from pathlib import Path

import tomllib


class Config:
    Filepath = Path().cwd() / "lovebrew.toml"

    Defaults_Wheel = resources.files("lovebrew") / "resources" / "lovebrew.toml"

    def __init__(self) -> None:
        if not Config.exists():
            return  # TODO: error

        self.data = dict()
        with open(Config.Filepath, "rb") as config:
            dict.update(self.data, tomllib.load(config))

        Path(self["build"]["saveDir"]).mkdir(exist_ok=True)

    def __getitem__(self, item) -> any:
        return self.data[item]

    @staticmethod
    def create() -> None:
        default_data = None
        if Path(Config.Defaults_Wheel).exists():
            default_data = Config.Defaults_Wheel.read_text()
        else:
            default_data = pkgutil.get_data("lovebrew", "lovebrew.toml").decode("UTF-8")

        with open(Config.Filepath, "w") as output:
            output.write(default_data.strip())

    @staticmethod
    def exists() -> bool:
        return Config.Filepath.exists()
