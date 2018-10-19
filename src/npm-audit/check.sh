#!/bin/bash -e

function main {
    # parse command line arguments
    local VERBOSE=yes
    local CONF_FILE=
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
        --conf-file=*)
            CONF_FILE="${i#*=}"
            shift
            ;;
        --target-dir=*)
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
        echo "Missing argument --target-dir"
    show_help
        exit 1
    fi

    echo "[ ] npm-audit"
    check "$VERBOSE" "$CONF_FILE" "$TARGET_DIR"
}

function show_help {
    echo "USAGE: check.sh [-v|--verbose] [-h|--help] [--conf-file=.devsecops-ci] --target-dir=/path/to/your/code"
}

function check {
    local VERBOSE=$1
    local CONF_FILE=$2
    local TARGET_DIR=$3
    local EXTRA_ARGS=
    local EXCLUDE=
    local FILES=
    local EXCLUDED_FILES=

    if [ -f "${TARGET_DIR}/${CONF_FILE}" ]; then
        EXCLUDE=`sed -e 's/[[:space:]]*\:[[:space:]]*/:/g' "${TARGET_DIR}/${CONF_FILE}" \
                 | sed -n '/^\[npm-audit\]/,/^\[.*\]/p' \
                 | grep "^[[:space:]]*exclude[[:space:]]*:" \
                 | sed 's/.*\:[[:space:]]*//' \
                 | sed 's/,/|/g'`
        if [ "$EXCLUDE" != "" ]; then
            FILES=`find "${TARGET_DIR}/" -type f -name 'package.json' -print | grep -Ev "${EXCLUDE}" | sed ':a;N;$!ba;s/\n/ /g'`
            EXCLUDED_FILES=`find "${TARGET_DIR}/" -type f -name 'package.json' -print | grep -E "${EXCLUDE}" | sed ':a;N;$!ba;s/\n/ /g'`
        else
            FILES=`find "${TARGET_DIR}/" -type f -name 'package.json' -print | sed ':a;N;$!ba;s/\n/ /g'`
        fi
    else
        FILES=`find "${TARGET_DIR}/" -type f -name 'package.json' -print | sed ':a;N;$!ba;s/\n/ /g'`
    fi
    if [ "$VERBOSE" == "yes" ]; then
        if [ "$EXCLUDED_FILES" != "" ]; then
            echo "[I] Excluded files:"
            for f in ${EXCLUDED_FILES}
            do
                echo "    - ${f#$TARGET_DIR/}"
            done
        fi
    fi
    for file in ${FILES}
    do
        echo "[I] Checking ${file#$TARGET_DIR/}"
        (cd "${file%/*}" && npm audit)
    done
}

main $@
