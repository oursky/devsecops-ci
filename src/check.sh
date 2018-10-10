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
    echo "DevSecOps - Performing checks on $TARGET_DIR."
    make check VERBOSE=$VERBOSE TARGET_DIR=$TARGET_DIR
    echo "[I] All check PASSED."
}

function show_help {
    echo "USAGE: check.sh [-v|--verbose] [-h|--help] -d=/path/to/your/code"
}


main $@
