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

    echo "[ ] go-sec"
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

    export GOPATH=/go
    mkdir -p "${GOPATH}/src"
    ln -s "${TARGET_DIR}" "${GOPATH}/src/app"

    if [ -f "${TARGET_DIR}/${CONF_FILE}" ]; then
        EXCLUDE=`sed -e 's/[[:space:]]*\:[[:space:]]*/:/g' "${TARGET_DIR}/${CONF_FILE}" \
                    | sed -n '/^\[go-sec\]/,/^\[.*\]/p' \
                    | grep "^[[:space:]]*exclude[[:space:]]*:" \
                    | sed 's/.*\:[[:space:]]*//'`
    fi

    FILES=`find "${GOPATH}/src/app/" -type f -name 'main.go' -print | grep -Ev vendor/ | sed ':a;N;$!ba;s/\n/ /g'`

    if [ "$VERBOSE" == "yes" ]; then
        echo "[I] Checked files:"
        for f in ${FILES}
        do
            echo "    - ${f#${GOPATH}/src/app/}"
        done
    fi
    if [ "$FILES" != "" ]; then
        ./bin/gosec --exclude=${EXCLUDE} ${FILES}
    fi
    # cleanup
    rm -f "${GOPATH}/src/app"
}

main $@
