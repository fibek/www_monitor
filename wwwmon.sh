#!/bin/env bash

WORK_DIR=$(mktemp -d)
ln -sn $WORK_DIR ./workdir # TODO: Remove; only in debug
SNAPSHOTS="$WORK_DIR/snapshots"
browser=$BROWSER
delay=600 # in seconds
OUT=/dev/null
tmpInputFile=$(mktemp -p "$WORK_DIR")
inputFile=''
URL=''

# trap cleanup TERM TODO: Fix this
trap cleanup SIGINT

function usage() {
    echo "Usage: $0 [OPTIONS] [URL]"
    echo "Options:"
    echo " -h    Display this help message"
    echo " -i    FILE Specify an input file with websites seperated with newline (then [URL] is)"
    echo " -b    FILE Either path to executable or name in \$PATH"
    echo " -f    FILE Print diff to file instead of opening browser"
    echo " -o    Run only once"
    echo " -d    INT  Specify delay (in seconds) between fetches"
}

function fetch() {
    echo 'fetch function'
    while true; do
        [[ ! -d "$SNAPSHOTS" ]] && mkdir "$SNAPSHOTS"
        wget -i "$tmpInputFile" \
            --quiet \
            --force-directories \
            --no-parent \
            --page-requisites \
            --keep-session-cookies \
            --save-cookies "$SNAPSHOTS/cookies" \
            --load-cookies "$SNAPSHOTS/cookies" \
            --directory-prefix "$SNAPSHOTS" \
            --no-cache \
            --backups=1
        ls -alR $SNAPSHOTS
        sleep "$delay"
        compare
    done;
}

function compare() {
    echo 'compare function'

}

function report() {
    echo 'report function'
}

function cleanup() {
    echo "cleanup!"
    rm -rf "$WORKDIR"
    rm ./workdir
    exit
}

function handle_options() {
    while getopts ":hi:b:d:f:" flag; do
        case $flag in
            h) # help
            usage
            ;;
            i) # input file
            inputFile=$OPTARG
            ;;
            b) # browser
            browser=$OPTARG 
            ;;
            d) # delay
            delay=$OPTARG 
            ;;
            f) # output
            OUT=$OPTARG 
            ;;
            \?)
            usage
            ;;
        esac
    done
    shift $((OPTIND -1)) # Last argument in URL
    URL=$1
    [[ ! -z "$inputFile" ]] && cat "$PWD/$inputFile" > "$tmpInputFile"
    echo "$URL" >> "$tmpInputFile"
    [[ $(wc -c < "$tmpInputFile") -eq 0 ]] && echo 'No URL or input file specified!' && usage || fetch
}

handle_options "$@"
