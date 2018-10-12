import re
import collections
import math


RE_WHITELIST_FILENAME = re.compile(".*require.*\.txt$"
                                   "|.*\.pbxproj$"
                                   "|.*\.xcworkspace\/"
                                   "|.*package\.json$"
                                   "|.*yarn\.lock$"
                                   "|.*\.htm[l]$"
                                   "|.*\.css$",
                                   re.IGNORECASE)
RE_BLACKLIST_FILENAME = re.compile(".*\.cer[t]$"
                                   "|.*\.key$"
                                   "|.*\.pem$",
                                   re.IGNORECASE)
RE_BLACKLIST_STRING = re.compile(".*"
                                 "(API[_]?KEY"
                                 "|SECRET"
                                 ")\s?=\s?[\'\"]?[0-9a-zA-Z]{12,}"
                                 "|SENTRY_DSN\s?=\s?[\'\"]?http",
                                 re.IGNORECASE)
RE_WORD_DELIMITER = re.compile("\s|\\|{|}|`|=|\(|\)|\[|\]|\/|<|>|\:|\@|\.")


# add known false posivive words here...
FALSE_POSITIVES = []


class SecretValidator():
    @staticmethod
    def whitelist_filename(filename):
        matched = RE_WHITELIST_FILENAME.match(filename)
        return matched is not None

    @staticmethod
    def blacklisted_filename(filename):
        matched = RE_BLACKLIST_FILENAME.match(filename)
        return matched is not None

    @staticmethod
    def blacklisted_keyword(text):
        if RE_BLACKLIST_STRING.match(text):
            return True
        return False

    @staticmethod
    def _shannon_entropy(s):
        probabilities = [n_x / len(s) for x, n_x
                                      in collections.Counter(s).items()]
        e_x = [-p_x * math.log(p_x, 2) for p_x in probabilities]
        return sum(e_x)

    @staticmethod
    def check_entropy(text, minlen=20, entropy=4.5):
        words = RE_WORD_DELIMITER.split(text)
        for word in words:
            if not word: continue
            if word[0] == '\'':
                word = word.strip('\'')
            elif word[0] == '\"':
                word = word.strip('\"')
            if len(word) < minlen:
                continue
            if word in FALSE_POSITIVES:
                continue
            h = SecretValidator._shannon_entropy(word)
            if h >= entropy:
                return True
        return False
