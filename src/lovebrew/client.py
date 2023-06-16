_LOVEBREW_ENDPOINT = "https://www.bundle.lovebrew.org/data"

import shutil
from pathlib import Path

import requests

from lovebrew.config import Config


def send_data(config: Config, target: str, app_version: int) -> tuple[bool, str, str]:
    if target == "cafe" and app_version < 3:
        return (False, None, "Cannot build for Wii U on app version < 3")

    params = {
        "title": config["metadata"]["title"],
        "description": config["metadata"]["description"],
        "author": config["metadata"]["author"],
        "version": config["metadata"]["version"],
        "mode": target,
        "app_version": str(app_version),
    }

    archive_name = shutil.make_archive("game", "zip", config["build"]["source"])
    extension = ".3dsx"

    match target:
        case "hac":
            extension = ".nro"
        case "cafe":
            extension = ".wuhb"

    filename = Path(archive_name).with_suffix(extension)

    files = {
        "game": open("game.zip", "rb"),
    }

    if config["metadata"]["icon"] != "":
        files["icon"] = open(config["metadata"]["icon"], "rb")

    response = requests.post(_LOVEBREW_ENDPOINT, params=params, files=files)

    if response.status_code != 200:
        return (False, None, response.content.decode("UTF-8"))

    return (True, filename.name, response.content)
