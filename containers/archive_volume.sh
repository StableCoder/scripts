#!/usr/bin/env bash

VOLUME=
OUTPUT=
COMPRESSION=zst

usage() {
    cat <<EOF
Script that archives a container volume

  Usage: ./archive_volume.sh [OPTIONS]

Options:
  -v | --volume <str>   Name of the docker volume to archive
  -o | --output <str>   Out filename
  --zstd                Compress with zstd (default)
  --bzip2               Compress with bzip2
  --gzip                Compress with gzip
EOF
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
        --zstd)
            COMPRESSION=zst
            shift
            ;;
        --bzip2)
            COMPRESSION=bz2
            shift
            ;;
        --gzip)
            COMPRESSION=gz
            shift
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
    sh -c "apt update && apt install bzip2 zstd && tar -capf /backup/$OUTPUT.tar.$COMPRESSION -C /volume ./"