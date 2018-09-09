#!/bin/bash

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -f)
    INPUT_FILE="$2"
    shift
    shift
    ;;
    --help)
    echo "This script allows for easier use of mass encrypted drives. It reads"
    echo "from a file given by -f <name> and has items within paired per-line as"
    echo "'<blkid> <mount point>', but still asks for the passphrase instead of"
    echo "looking for a file."
    exit 0
    ;;
esac
done

if [ "$INPUT_FILE" != "" ]; then
    # Read the input file for block IDs and mapping locations.
    i=0
    while read line
    do
        IN_FILEARR[$i]="$line"
        i=$((i+1))
    done < $INPUT_FILE
fi

i=0
while read line
do
    IN_BLKARR[$i]="$line"
    i=$((i+1))
done< <(blkid)

for blkid_line in "${IN_BLKARR[@]}"
do
    for file_line in "${IN_FILEARR[@]}"
    do
        file_blkid=$( echo $file_line | cut -d " " -f 1)
        file_mnt=$( echo $file_line | cut -d " " -f 2)
        blkid_dev=$( echo $blkid_line | cut -d ":" -f 1)
        # Search for the file line that has a matching block ID
        if [[ $blkid_line == *$file_blkid* ]]
        then
            echo "Found matching blkid for $file_blkid, with target of $file_mnt"
            i=0
            map_name="encrypted$i"
            while [ $(ls /dev/mapper/$map_name) ]
            do
                i=$((i+1))
                map_name="encrypted$i"
            done
            cryptsetup open $blkid_dev $map_name
            mkdir -p $file_mnt
            mount /dev/mapper/$map_name $file_mnt
        fi
    done
done