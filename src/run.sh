#!/bin/bash -e

function main {
    # parse command line arguments
    for i in "$@"
    do
        case $i in
        -d=*|--directory=*)
            TARGET_DIR="${i#*=}"
            shift
            ;;
        -h=*|--help=*)
            show_help
            exit 0
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
    make check TARGET_DIR=$TARGET_DIR
    echo "[I] All check PASSED."
}

function show_help {
    echo "USAGE: run.sh -d=/path/to/your/code"
}


main $@
