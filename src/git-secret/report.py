import enum
from collections import namedtuple
from arguments import Arguments


class ReportCode(enum.Enum):
    SUCCESS = 0
    UNSUPPORTED = 1
    FAILED = 2


ReportSeverityLevelTupe = namedtuple('SeverityLevel',
                                     ['code', 'short'])
class ReportSeverityLevel(enum.Enum):
    INFO = ReportSeverityLevelTupe(0, 'I')
    WARN = ReportSeverityLevelTupe(1, 'W')
    ERROR = ReportSeverityLevelTupe(2, 'E')

    @property
    def code(self):
        return self.value.code

    @property
    def short(self):
        return self.value.short


ReportIncidentCodeTupe = namedtuple('IncidentCode',
                                           ['code',
                                            'description'])
class ReportIncidentCode(enum.Enum):
    BLACKLIST_FILENAME = ReportIncidentCodeTupe('B001', 'Blacklisted filename')
    BLACKLIST_STRING = ReportIncidentCodeTupe('E001', 'Blacklisted string')
    ENTROPY_STRING = ReportIncidentCodeTupe('E002', 'High entropy string')

    @property
    def code(self):
        return self.value.code

    @property
    def description(self):
        return self.value.description


class ReportIncident():
    Code = ReportIncidentCode

    def __init__(self, serverity, code, filename: str, offend: str, author: str):
        self.serverity = serverity
        self.code = code
        self.filename = filename
        self.offend = offend
        self.author = author

    def dump(self, verbose=True):
        if not verbose and (self.serverity == ReportSeverityLevel.INFO or self.serverity == ReportSeverityLevel.WARN):
            return
        print("- [{serverity}:{code}] {message}\n"
              "           File  : {file}\n"
              "           Author: {author}".format(
                serverity=self.serverity.short,
                code=self.code.code,
                file=self.filename,
                offend=self.offend,
                author=self.author,
                message=self.code.description))
        if self.serverity == Report.SeverityLevel.ERROR and self.offend:
            print("         * Offend: {}".format(self.offend))


class Report:
    Code = ReportCode
    SeverityLevel = ReportSeverityLevel
    Incident = ReportIncident

    def __init__(self, code=ReportCode.FAILED):
        self.code = code
        self.incidents = []

    def dump(self, verbose=True):
        print("[ ] Scan result: {}".format(self.code.name))

        reordered = sorted(self.incidents, key=lambda x: x.serverity.code, reverse=True)
        for incident in reordered:
            incident.dump(verbose)
