import re
import shlex
import collections
import math


class SecretValidator():
    @staticmethod
    def whitelist_filename(filename):
        ex = ".*\/require.*\.txt|.*\.pbxproj|.*package.json|.*yarn.lock"
        matched = re.compile(ex).match(filename)
        return matched is not None

    @staticmethod
    def blacklisted_filename(filename):
        ex = ".*\.cer|.*\.cert|.*\.key|.*\.pem"
        matched = re.compile(ex).match(filename)
        return matched is not None

    @staticmethod
    def _shannon_entropy(s):
        probabilities = [n_x / len(s) for x, n_x
                                      in collections.Counter(s).items()]
        e_x = [-p_x * math.log(p_x, 2) for p_x in probabilities]
        return sum(e_x)

    @staticmethod
    def check_entropy(text, minlen=20, entropy=4.6):
        try:
            words = shlex.split(text.replace("\\", '')
                                    .replace('{', '')
                                    .replace('}', '')
                                    .replace('`', ''))
        except ValueError:
            words = [text]

        # further split words with =
        words2 = []
        for word in words:
            if not word: continue
            if word[0] == '\'' or word[0] == '\"':
                words2.append(word)
            else:
                words2.extend(word.split('='))

        for word in words2:
            if not word: continue
            if word[0] == '\'':
                word = word.strip('\'')
            elif word[0] == '\"':
                word = word.strip('\"')
            if len(word) < minlen:
                continue
            h = SecretValidator._shannon_entropy(word)
            if h >= entropy:
                return True
        return False
