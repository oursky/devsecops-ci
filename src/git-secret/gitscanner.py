import enum
import re
from git import Repo, NULL_TREE
from git.exc import InvalidGitRepositoryError, NoSuchPathError
from arguments import Arguments
from scanner import Scanner, ScannerReport
from validator import SecretValidator


class GitScanner(Scanner):
    def __init__(self, args: Arguments):
        self._verbose = args.verbose
        self._repo_dir = args.target_dir
        self._commit_range = args.commit_range
        self._exclude = args.config.exclude
        pass

    def _is_excluded(self, filename):
        if SecretValidator.whitelist_filename(filename):
            return True
        if not self._exclude:
            return False
        return re.compile(self._exclude).match(filename) != None

    def _parse_rev_range(self, revs):
        if revs:
            if "..." in self._commit_range:
                revA, revB = self._commit_range.split("...", 2)
            elif ".." in self._commit_range:
                revA, revB = self._commit_range.split("..", 2)
            else:
                revA = self._commit_range
                revB = None
        else:
            revA = None
            revB = None
        return revA, revB

    def scan(self):
        report = ScannerReport()
        try:
            repo = Repo(self._repo_dir)
            if repo.bare:
                report.code = ScannerReport.Code.UNSUPPORTED
                return report
        except (InvalidGitRepositoryError, NoSuchPathError):
            report.code = ScannerReport.Code.UNSUPPORTED
            return report

        commits = list(repo.iter_commits())
        # filter revisions
        revA, revB = self._parse_rev_range(self._commit_range)
        if revA or revB:
            revAIndex = len(commits) - 1
            revBIndex = 0
            for index in reversed(range(len(commits))):
                if commits[index].hexsha == revA:
                    revAIndex = index + 1
                    break
            for index in range(len(commits)):
                if commits[index].hexsha == revB:
                    revBIndex = index
                    break
            commits = commits[revBIndex:revAIndex]

        if self._verbose:
            print("[I] Check for revision: ", self._commit_range or "all")
            print("[I] Number of commits: ", len(commits) -1)

        # look into commit diffs
        for index in range(len(commits) - 1):
            commit1 = commits[index]
            commit2 = commits[index+1]

            if self._verbose:
                print("[I] {} -> {}".format(commit1.hexsha, commit2.hexsha))
            else:
                print('.', end='', flush=True)

            for diff in commit2.diff(commit1, create_patch=True):
                filename = diff.b_path
                if not filename:
                    continue  # skip deleted file
                filename = filename.strip(" ")
                # Check for blacklisted filename
                if SecretValidator.blacklisted_filename(filename):
                    serverity = ScannerReport.SeverityLevel.WARN \
                                if self._is_excluded(filename) \
                                else ScannerReport.SeverityLevel.ERROR
                    report.incidents.append(
                            ScannerReport.Incident(
                                serverity=serverity,
                                code=ScannerReport.Incident.Code.BLACKLIST_FILENAME,
                                filename=filename,
                                offend=None,
                                author=commit2.author.name))

                # Check for string entropy
                for line in str(diff).splitlines():
                    if not line or line[0] != '+': continue
                    line = line[1:]
                    if SecretValidator.check_entropy(line):
                        serverity = ScannerReport.SeverityLevel.WARN \
                                    if self._is_excluded(filename) \
                                    else ScannerReport.SeverityLevel.ERROR
                        report.incidents.append(
                                ScannerReport.Incident(
                                    serverity=serverity,
                                    code=ScannerReport.Incident.Code.ENTROPY_STRING,
                                    filename=filename,
                                    offend=line,
                                    author=commit2.author.name))
                        break
        if not self._verbose:
            print("")

        # check if any error incident
        report.code = ScannerReport.Code.SUCCESS
        for incident in report.incidents:
            if incident.serverity == ScannerReport.SeverityLevel.ERROR:
                report.code = ScannerReport.Code.FAILED
                break
        return report
