from configparser import ConfigParser
from dataclasses import dataclass


@dataclass
class Config():
    exclude: str = None
    allow_secrets = []

    @staticmethod
    def load(conf_file):
        parser = ConfigParser(delimiters=(":"))
        parser.read(conf_file)
        try:
            exclude = parser.get('git-secret', 'exclude').strip(" ")
        except Exception:
            exclude = None
        try:
            v = parser.get('git-secret', 'allow_secrets').strip(" ")
            allow_secrets = [x.strip() for x in v.splitlines()]
        except Exception:
            allow_secrets = []

        config = Config()
        config.exclude = exclude
        config.allow_secrets = allow_secrets
        return config
