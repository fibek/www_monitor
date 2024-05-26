#!/bin/env bash

WORK_DIR=$(mktemp -d)
browser=$BROWSER
delay=10m
OUT=/dev/null
inputfilename=$(mktemp)
URL=''

function usage() {
    echo "Usage: $0 [OPTIONS] [URL]"
    echo "Options:"
    echo " -h, --help      Display this help message"
    echo " -f, --file      FILE Specify an input file with websites seperated with newline (then [URL] is)"
    echo " -b, --browser   FILE Either path to executable or name in \$PATH"
    echo " -o, --output    FILE Print diff to file instead of opening browser"
    echo " -d, --delay     INT  Specify delay between fetches"
}

function fetch() {
    [[ ! -d "$WORK_DIR/snapshots" ]] && mkdir "$WORK_DIR/snapshots"
    cd "$WORK_DIR" && wget -i "$inputfilename"
    i=0
    for file in *; do
        url=${inputfilename[i]}
        echo $url
        # mv $WORK_DIR/$file $WORK_DIR/$url/snapshot_$(date +%F-%H_%M)
        i=i+1
    done;
}

function compare() {
    echo 'compare function'
}

function report() {
    echo 'report function'
}

function handle_options() {
    while getopts ":hi:b:d:o:" flag; do
        case $flag in
            h) # help
            usage
            ;;
            i) # input file
            inputfilename=$OPTARG
            ;;
            b) # browser
            browser=$OPTARG 
            ;;
            d) # delay
            delay=$OPTARG 
            ;;
            o) # output
            OUT=$OPTARG 
            ;;
            \?)
            usage
            ;;
        esac
    done
    shift $((OPTIND -1)) # Last argument in URL
    URL=$1
    echo "$URL" >> "$inputfilename"
    [[ -z "$(cat $inputfilename)" ]] && echo 'No URL or input file specified!' && usage
}

handle_options "$@"