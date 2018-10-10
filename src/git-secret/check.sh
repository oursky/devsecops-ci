#!/bin/bash -e

function main {
    # parse command line arguments
    local VERBOSE=yes
    local TARGET_DIR=

    for i in "$@"
    do
        case $i in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=yes
            shift
            ;;
        -v=*|--verbose=*)
            VERBOSE="${i#*=}"
            shift
            ;;
        -d=*|--directory=*)
            TARGET_DIR="${i#*=}"
            shift
            ;;
        *)
            shift
            ;;
        esac
    done
    # validate arguments
    if [ ! -d "$TARGET_DIR" ]; then
        echo "Missing argument -d"
        exit 1
    fi

    echo "[ ] git-secret"
    check "$TARGET_DIR" "$VERBOSE"
}

function show_help {
    echo "USAGE: check.sh [-v|--verbose] [-h|--help] -d=/path/to/your/code"
}

function check {
    local TARGET_DIR=$1
    local VERBOSE=$2
    local EXCLUDE=
    local FILES=`(cd "${TARGET_DIR}" && git ls-files)`
    local has_error=no

    if [ ! -d "${TARGET_DIR}/.git" ]; then
        echo "[W] Not a git repository!"
        exit 0
    fi

    if [ -f "${TARGET_DIR}/devsecops-ci.conf" ]; then
        EXCLUDE=`sed -e 's/[[:space:]]*\:[[:space:]]*/:/g' "${TARGET_DIR}/devsecops-ci.conf" \
                 | sed -n '/^\[git-secret\]/,/^\[.*\]/p' \
                 | grep "^[[:space:]]*exclude[[:space:]]*:" \
                 | sed 's/.*\:[[:space:]]*//' \
                 | sed 's/,/ /g'`
    fi

    for f in ${FILES}
    do
        if [[ "$f" =~ ^(.env|.*\.cer|.*\.cert|.*\.key|.*\.pem)$ ]]; then
            if [[ "${EXCLUDE}" == *"$f"* ]]; then
                echo "[W] Potential secret: $f (ignored)"
            else
                echo "[E] Potential secret: $f"
                has_error=yes
            fi
        fi
    done

    if [ "$has_error" != "no" ]; then
        exit 1
    fi
}

main $@
