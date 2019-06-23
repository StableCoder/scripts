#!/bin/bash

VOLUME=
OUTPUT=

usage() {
    printf "Script that archives a Docker volume\n\n"
    printf "  Usage: ./archive_volume.sh [OPTIONS]\n\n"
    printf "Options:\n"
    printf "  -v <str> | --volume <str>  Name of the docker volume to archive.\n"
    printf "  -o <str> | --output <str>  Out filename (.tar.bz2 is auto added)\n\n"
    exit
}

while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -v|--volume)
            VOLUME="$2"
            shift # past argument
            shift # past value
            ;;
        -o|--output)
            OUTPUT="$2"
            shift # past argument
            shift # past value
            ;;
        *)    # unknown option
            usage
            ;;
    esac
done

if [ "$VOLUME" == "" ]
then
    read -p "Please enter the name of the volume to archive: " VOLUME
fi
if [ "$OUTPUT" == "" ]
then
    OUTPUT=$VOLUME-$(date +%Y-%m-%d-%H-%M-%S)
fi

docker run --rm -it -v $VOLUME:/volume -v /$(pwd):/backup ubuntu:latest \
    tar -cjpf /backup/$OUTPUT.tar.bz2 -C /volume ./