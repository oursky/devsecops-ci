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

    echo "[ ] py-bandit"
    check "$VERBOSE" "$CONF_FILE" "$TARGET_DIR"
}

function show_help {
    echo "USAGE: check.sh [-v|--verbose] [-h|--help] [--conf-file=.devsecops-ci] --target-dir=/path/to/your/code"
}

function check {
    local VERBOSE=$1
    local CONF_FILE=$2
    local TARGET_DIR=$3
    local INI_FLAG=

    if [ "$CONF_FILE" != "" ]; then
      if [ -f "${TARGET_DIR}/${CONF_FILE}" ]; then
        INI_FLAG="--ini ${TARGET_DIR}/${CONF_FILE}"
      fi
    fi
    bandit ${INI_FLAG} -r "${TARGET_DIR}"
}

main $@
