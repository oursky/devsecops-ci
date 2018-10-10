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

    echo "[ ] py-safety"
    check "$TARGET_DIR" "$VERBOSE"
}

function show_help {
    echo "USAGE: check.sh [-v|--verbose] [-h|--help] -d=/path/to/your/code"
}

function check {
    local TARGET_DIR=$1
    local VERBOSE=$2
    local EXTRA_ARGS=
    local EXCLUDE=
    local FILES=

    if [ -f "${TARGET_DIR}/devsecops-ci.conf" ]; then
        EXTRA_ARGS=`sed -e 's/[[:space:]]*\:[[:space:]]*/:/g' "${TARGET_DIR}/devsecops-ci.conf" \
                    | sed -n '/^\[py-safety\]/,/^\[.*\]/p' \
                    | grep "^[[:space:]]*arguments[[:space:]]*:" \
                    | sed 's/.*\:[[:space:]]*//'`
        EXCLUDE=`sed -e 's/[[:space:]]*\:[[:space:]]*/:/g' "${TARGET_DIR}/devsecops-ci.conf" \
                 | sed -n '/^\[py-safety\]/,/^\[.*\]/p' \
                 | grep "^[[:space:]]*exclude[[:space:]]*:" \
                 | sed 's/.*\:[[:space:]]*//' \
                 | sed 's/,/ /g' \
                 | sed 's/.*/-type d -name & -prune -o/g'`
    fi

    FILES=`find "${TARGET_DIR}/" ${EXCLUDE} -type f -name 'require*.txt' -print | sed ':a;N;$!ba;s/\n/ /g'`
    if [ "$VERBOSE" == "yes" ]; then
        echo "[I] Checked files:"
        for f in ${FILES}
        do
            echo "    - $f"
        done
    fi
    safety check --cache --full-report \
        ${EXTRA_ARGS} \
        `echo ${FILES} | sed 's/[^ ]* */-r &/g'`
}

main $@
