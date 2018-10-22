import sys
from arguments import Arguments
from report import Report
from scanner import GitScanner

def main():
    print("[ ] git-secret scanner")

    args = Arguments.parse(sys.argv[1:])
    if args is None or args.help:
        print(Arguments.helptext())
        sys.exit(1)

    has_error = False

    scanner = GitScanner(args)
    report = scanner.scan()
    report.dump()
    if report.code == Report.Code.FAILED:
        has_error = True

    if has_error:
        sys.exit(1)


if __name__ == "__main__":
    main()
