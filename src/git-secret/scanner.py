import enum
from abc import ABC, abstractmethod
from collections import namedtuple
from arguments import Arguments


class ScannerReportCode(enum.Enum):
    SUCCESS = 0
    UNSUPPORTED = 1
    FAILED = 2


ScannerReportSeverityLevelTupe = namedtuple('SeverityLevel',
                                            ['code', 'short'])

class ScannerReportSeverityLevel(enum.Enum):
    INFO = ScannerReportSeverityLevelTupe(0, 'I')
    WARN = ScannerReportSeverityLevelTupe(1, 'W')
    ERROR = ScannerReportSeverityLevelTupe(2, 'E')

    @property
    def code(self):
        return self.value.code

    @property
    def short(self):
        return self.value.short

ScannerReportIncidentCodeTupe = namedtuple('IncidentCode',
                                           ['code',
                                            'description'])

class ScannerReportIncidentCode(enum.Enum):
    BLACKLIST_FILENAME = ScannerReportIncidentCodeTupe('B001', 'Blacklisted filename')
    BLACKLIST_STRING = ScannerReportIncidentCodeTupe('E001', 'Blacklisted string')
    ENTROPY_STRING = ScannerReportIncidentCodeTupe('E002', 'High entropy string')

    @property
    def code(self):
        return self.value.code

    @property
    def description(self):
        return self.value.description

class ScannerReportIncident():
    Code = ScannerReportIncidentCode

    def __init__(self, serverity, code, filename: str, offend: str, author: str):
        self.serverity = serverity
        self.code = code
        self.filename = filename
        self.offend = offend
        self.author = author

    def dump(self):
        print("- [{serverity}:{code}] {message}\n"
              "           File  : {file}\n"
              "           Author: {author}".format(
                serverity=self.serverity.short,
                code=self.code.code,
                file=self.filename,
                offend=self.offend,
                author=self.author,
                message=self.code.description))
        if self.serverity == ScannerReport.SeverityLevel.ERROR and self.offend:
            print("         * Offend: {}".format(self.offend))


class ScannerReport:
    Code = ScannerReportCode
    SeverityLevel = ScannerReportSeverityLevel
    Incident = ScannerReportIncident

    def __init__(self, code=ScannerReportCode.FAILED):
        self.code = code
        self.incidents = []

    def dump(self):
        print("[ ] Scan result: {}".format(self.code.name))

        reordered = sorted(self.incidents, key=lambda x: x.serverity.code, reverse=True)
        for incident in reordered:
            incident.dump()

class Scanner(ABC):
    """!
    ctor
    @param args: Arguments
    """
    @abstractmethod
    def __init__(self, args: Arguments):
        pass

    """!
    Run scanner
    @return ScannerReport
    """
    @abstractmethod
    def scan(self):
        pass
