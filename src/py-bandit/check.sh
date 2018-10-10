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

    echo "[ ] py-bandit"
    check "$TARGET_DIR" "$VERBOSE"
}

function show_help {
    echo "USAGE: check.sh [-v|--verbose] [-h|--help] -d=/path/to/your/code"
}

function check {
    local TARGET_DIR=$1
    local VERBOSE=$2
    local VERBOSE_FLAG=
    local INI_FLAG=

    if [ -f "${TARGET_DIR}/devsecops-ci.conf" ]; then
        INI_FLAG="--ini ${TARGET_DIR}/devsecops-ci.conf"
    fi
    bandit ${INI_FLAG} -r "${TARGET_DIR}"
}

main $@
