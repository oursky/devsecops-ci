import re
from git import Repo
from git.exc import InvalidGitRepositoryError, NoSuchPathError
from arguments import Arguments
from checker import SecretChecker
from report import Report


class GitScanner():
    def __init__(self, args: Arguments):
        self._verbose = args.verbose
        self._repo_dir = args.target_dir
        self._commit_range = args.commit_range
        self._exclude = re.compile(args.config.exclude) \
                        if args.config.exclude else None
        self._allow_secrets = args.config.allow_secrets
        pass

    def _is_excluded(self, filename):
        if not self._exclude:
            return False
        return self._exclude.match(filename) != None

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

    def _githash_equal(self, hash1, hash2):
        if not hash1 or not hash2:
            return hash1 == hash2
        if len(hash1) == 12:  # short sha
            return hash2.startswith(hash1)
        elif len(hash2) == 12:
            return hash1.startswith(hash2)
        return hash1 == hash2

    def scan(self):
        report = Report()
        try:
            repo = Repo(self._repo_dir)
            if repo.bare:
                report.code = Report.Code.UNSUPPORTED
                return report
        except (InvalidGitRepositoryError, NoSuchPathError):
            report.code = Report.Code.UNSUPPORTED
            return report

        commits = list(repo.iter_commits())
        # filter revisions
        revA, revB = self._parse_rev_range(self._commit_range)
        if revA or revB:
            revAIndex = len(commits) - 1
            revBIndex = 0
            for index in reversed(range(len(commits))):
                if self._githash_equal(commits[index].hexsha, revA):
                    revAIndex = index + 1
                    break
            for index in range(len(commits)):
                if self._githash_equal(commits[index].hexsha, revB):
                    revBIndex = index
                    break
            commits = commits[revBIndex:revAIndex]

        if self._verbose:
            print("[I] Check for revision: ", self._commit_range or "all")
            print("[I] Number of commits: ", len(commits) -1)

        # look into commit diffs
        for index in reversed(range(len(commits) - 1)):
            commit1 = commits[index]
            commit2 = commits[index+1]

            if self._verbose:
                print("[I] {} -> {}".format(commit2.hexsha, commit1.hexsha))
            else:
                print('.', end='', flush=True)

            for diff in commit2.diff(commit1, create_patch=True):
                filename = diff.b_path
                if not filename:
                    continue  # skip deleted file
                filename = filename.strip(" ")

                if SecretChecker.whitelist_filename(filename):
                    continue

                # Check for blacklisted filename
                if SecretChecker.blacklisted_filename(filename):
                    serverity = Report.SeverityLevel.WARN \
                                if self._is_excluded(filename) \
                                else Report.SeverityLevel.ERROR
                    report.incidents.append(
                            Report.Incident(
                                serverity=serverity,
                                code=Report.Incident.Code.BLACKLIST_FILENAME,
                                filename=filename,
                                offend=None,
                                author=commit2.author.name))



                for line in str(diff).splitlines():
                    if not line or line[0] != '+': continue
                    line = line[1:].strip()
                    # Check for blacklisted keywords
                    if SecretChecker.blacklisted_keyword(line):
                        serverity = Report.SeverityLevel.WARN \
                                    if self._is_excluded(filename) \
                                    else Report.SeverityLevel.ERROR
                        report.incidents.append(
                                Report.Incident(
                                    serverity=serverity,
                                    code=Report.Incident.Code.BLACKLIST_STRING,
                                    filename=filename,
                                    offend=line,
                                    author=commit2.author.name))
                        continue  # no need to check entropy
                    # Check for string entropy
                    offend = SecretChecker.check_entropy(line, self._allow_secrets)
                    if offend:
                        serverity = Report.SeverityLevel.WARN \
                                    if self._is_excluded(filename) \
                                    else Report.SeverityLevel.ERROR
                        report.incidents.append(
                                Report.Incident(
                                    serverity=serverity,
                                    code=Report.Incident.Code.ENTROPY_STRING,
                                    filename=filename,
                                    offend=offend,
                                    author=commit2.author.name))
        if not self._verbose:
            print("")

        # check if any error incident
        report.code = Report.Code.SUCCESS
        for incident in report.incidents:
            if incident.serverity == Report.SeverityLevel.ERROR:
                report.code = Report.Code.FAILED
                break
        return report
