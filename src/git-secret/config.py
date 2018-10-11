from configparser import ConfigParser
from dataclasses import dataclass


@dataclass
class Config():
    exclude: str = None

    @staticmethod
    def load(conf_file):
        parser = ConfigParser(delimiters=(":"))
        parser.read(conf_file)
        try:
            exclude = parser['git-secret']['exclude'].strip(" ")
        except Exception:
            exclude = None

        config = Config()
        config.exclude = exclude
        return config
