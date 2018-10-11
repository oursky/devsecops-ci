import enum
from abc import ABC, abstractmethod
from collections import namedtuple
from arguments import Arguments


class ScannerReportCode(enum.Enum):
    SUCCESS = 0
    UNSUPPORTED = 1
    FAILED = 2


ScannerReportSeverityLevelTupe = namedtuple('SeverityLevel',
                                            ['value', 'short'])

class ScannerReportSeverityLevel(enum.Enum):
    INFO = ScannerReportSeverityLevelTupe(0, 'I')
    WARN = ScannerReportSeverityLevelTupe(1, 'W')
    ERROR = ScannerReportSeverityLevelTupe(2, 'E')

    @property
    def short(self):
        return self.value.short

ScannerReportIncidentCodeTupe = namedtuple('IncidentCode',
                                           ['code',
                                            'description'])

class ScannerReportIncidentCode(enum.Enum):
    BLACKLIST_FILENAME = ScannerReportIncidentCodeTupe('B001', 'Blacklisted filename')
    ENTROPY_STRING = ScannerReportIncidentCodeTupe('E001', 'High entropy string')

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


class ScannerReport:
    Code = ScannerReportCode
    SeverityLevel = ScannerReportSeverityLevel
    Incident = ScannerReportIncident

    def __init__(self, code=ScannerReportCode.FAILED):
        self.code = code
        self.incidents = []

    def dump(self):
        print("[ ] Scan result: ".format(self.code.name))
        for incident in self.incidents:
            print("- [{serverity}:{code}] {message}\n"
                  "           File  : {file}\n"
                  "           Author: {author}".format(
                serverity=incident.serverity.short,
                code=incident.code.code,
                file=incident.filename,
                offend=incident.offend,
                author=incident.author,
                message=incident.code.description))
            if incident.serverity == ScannerReport.SeverityLevel.ERROR and incident.offend:
                print("           Offend: {}".format(incident.offend))

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
