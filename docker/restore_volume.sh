#!/bin/bash

VOLUME=
FILE=
DATE=$(date +%Y-%m-%d-%H-%M-%S)

usage() {
    printf "Script that archives a Docker volume\n\n"
    printf "  Usage: ./archive_volume.sh [OPTIONS]\n\n"
    printf "Options:\n"
    printf "  -f <str> | --file <str>    Archive file to restore to the volume.\n"
    printf "  -v <str> | --volume <str>  Name of the docker volume to restore to.\n\n"
    exit
}

while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -f | --file)
            FILE="$2"
            shift
            shift
            ;;
        -v|--volume)
            VOLUME="$2"
            shift # past argument
            shift # past value
            ;;
        *)    # unknown option
            usage
            ;;
    esac
done

if [ "$FILE" == "" ]
then
    read -p "Please enter the filename of the archive to restore: " -e FILE
fi
if [ "$VOLUME" == "" ]
then
    read -p "Please enter the name of the volume to restore to: " VOLUME
fi

docker run --rm -it -v $VOLUME:/volume -v /$(pwd):/backup alpine \
    sh -c "rm -rf /volume/* /volume/..?* /volume/.[!.]* ; tar --same-owner -C /volume/ -xjpf /backup/$FILE"