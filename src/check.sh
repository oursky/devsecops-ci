#!/bin/bash -e

function main {
    # parse command line arguments
    local VERBOSE=yes
    local CONF_FILE=.devsecops-ci
    local TARGET_DIR=
    local COMMIT_RANGE=

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
        --conf-file-dir=*)
            CONF_FILE="${i#*=}"
            shift
            ;;
        --target-dir=*)
            TARGET_DIR="${i#*=}"
            shift
            ;;
        --commit-range=*)
            COMMIT_RANGE="${i#*=}"
            shift
            ;;
        *)
            shift
            ;;
        esac
    done
    # validate arguments
    if [ ! -d "$TARGET_DIR" ]; then
        echo "Missing argument -t"
        exit 1
    fi
    echo "DevSecOps - Performing checks on $TARGET_DIR."
    make check VERBOSE="$VERBOSE" CONF_FILE="$CONF_FILE" TARGET_DIR="$TARGET_DIR" COMMIT_RANGE="$COMMIT_RANGE"
    echo "[I] All check PASSED."
}

function show_help {
    echo "USAGE: check.sh [-v|--verbose] [-h|--help] -d=/path/to/your/code"
}


main $@
